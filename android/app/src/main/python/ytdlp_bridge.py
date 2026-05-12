"""
Bridge module for yt-dlp integration.

This module is called from Kotlin via Chaquopy to resolve direct download URLs
from any supported video platform (YouTube, Instagram, TikTok, Twitter/X,
Facebook, Vimeo, and 1000+ others). We use yt-dlp for both URL resolution and
direct downloading.
"""

import json
import yt_dlp


def extract_info_json(video_url):
    """
    Extract video metadata and all available formats from any supported URL.

    Args:
        video_url: Video URL from any platform supported by yt-dlp.

    Returns:
        JSON string with: id, title, uploader, thumbnail, duration, and
        a list of formats — each with format_id, ext, resolution, width,
        height, filesize, vcodec, acodec, tbr, abr, format_note.
        Or JSON with error key on failure.
    """
    try:
        ydl_opts = {
            "quiet": True,
            "no_warnings": True,
            "skip_download": True,
        }

        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(video_url, download=False)
            if info is None:
                return json.dumps({"error": "yt-dlp returned no info"})

            formats = []
            for f in info.get("formats", []):
                vcodec = f.get("vcodec", "none") or "none"
                acodec = f.get("acodec", "none") or "none"

                # Skip storyboard / poster / manifest-only entries
                if vcodec == "none" and acodec == "none":
                    continue

                formats.append({
                    "format_id": str(f.get("format_id", "")),
                    "ext": f.get("ext", "mp4"),
                    "resolution": f.get("resolution", ""),
                    "width": f.get("width") or 0,
                    "height": f.get("height") or 0,
                    "filesize": f.get("filesize") or f.get("filesize_approx") or 0,
                    "vcodec": vcodec,
                    "acodec": acodec,
                    "tbr": f.get("tbr") or 0,
                    "abr": f.get("abr") or 0,
                    "format_note": f.get("format_note", ""),
                })

            result = {
                "id": info.get("id", ""),
                "title": info.get("title", "Unknown Title"),
                "uploader": info.get("uploader") or info.get("channel") or "Unknown",
                "thumbnail": info.get("thumbnail", ""),
                "duration": info.get("duration") or 0,
                "formats": formats,
            }
            return json.dumps(result)

    except Exception as e:
        return json.dumps({"error": str(e)})


def resolve_stream_url(video_url, itag):
    """
    Resolve a direct download URL for a specific YouTube stream itag.

    Args:
        video_url: YouTube video URL (e.g. https://youtube.com/watch?v=xxx)
        itag: YouTube stream itag number (as string, e.g. "18", "137")

    Returns:
        JSON string with: url, filesize, ext, format_note
        Or JSON with error key on failure.
    """
    try:
        ydl_opts = {
            "quiet": True,
            "no_warnings": True,
            # Don't download, just extract info
            "skip_download": True,
        }

        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(video_url, download=False)

            # Find the format matching the requested itag
            for f in info.get("formats", []):
                if str(f.get("format_id")) == str(itag):
                    return json.dumps({
                        "url": f["url"],
                        "filesize": f.get("filesize") or f.get("filesize_approx", 0),
                        "ext": f.get("ext", "mp4"),
                        "http_headers": f.get("http_headers", {}),
                    })

            return json.dumps({"error": f"Format itag {itag} not found"})

    except Exception as e:
        return json.dumps({"error": str(e)})


def resolve_best_urls(video_url, video_itag, audio_itag=None):
    """
    Resolve direct URLs for video and optionally audio streams.

    Used when downloading video-only + audio-only streams that need merging.

    Args:
        video_url: YouTube video URL
        video_itag: itag for the video stream
        audio_itag: itag for the audio stream (None if muxed/audio-only)

    Returns:
        JSON string with video_url, audio_url (if applicable), and http_headers.
    """
    try:
        ydl_opts = {
            "quiet": True,
            "no_warnings": True,
            "skip_download": True,
        }

        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(video_url, download=False)
            formats = {str(f["format_id"]): f for f in info.get("formats", [])}

            result = {}

            # Resolve video/primary stream
            vf = formats.get(str(video_itag))
            if not vf:
                return json.dumps({"error": f"Video itag {video_itag} not found"})
            result["video_url"] = vf["url"]
            result["video_size"] = vf.get("filesize") or vf.get("filesize_approx", 0)
            result["http_headers"] = vf.get("http_headers", {})

            # Resolve audio stream if needed
            if audio_itag:
                af = formats.get(str(audio_itag))
                if not af:
                    return json.dumps({"error": f"Audio itag {audio_itag} not found"})
                result["audio_url"] = af["url"]
                result["audio_size"] = af.get("filesize") or af.get("filesize_approx", 0)

            return json.dumps(result)

    except Exception as e:
        return json.dumps({"error": str(e)})


# ---------------------------------------------------------------------------
# Direct download via yt-dlp — mirrors the standalone Python CLI.
# This is the same mechanism yt-dlp uses from the terminal (segmented
# `&range=` GETs, proper headers, automatic retry), so it achieves full
# bandwidth on YouTube instead of being throttled.
# ---------------------------------------------------------------------------

class _DownloadCancelled(Exception):
    """Raised from a progress hook to abort yt-dlp."""
    pass


def download_stream(video_url, itag, output_path_template, phase):
    """
    Download a single YouTube stream (video-only, audio-only, or muxed)
    directly using yt-dlp. Progress is emitted back to the Android UI via
    the MainActivity static bridge.

    Args:
        video_url: YouTube video URL.
        itag: Format id (string) to download.
        output_path_template: File path template (can contain %(ext)s).
        phase: Human-readable phase label forwarded with progress events.

    Returns:
        JSON string {"path": "<final file path>"} or {"error": "..."}.
    """
    try:
        from java import jclass
        MainActivity = jclass("com.omni.downloader.MainActivity")
    except Exception:
        MainActivity = None

    def _is_cancelled():
        if MainActivity is None:
            return False
        try:
            return bool(MainActivity.isCancelled())
        except Exception:
            return False

    def _emit(status, downloaded, total, speed, ph):
        if MainActivity is None:
            return
        try:
            MainActivity.emitProgress(
                str(status),
                int(downloaded or 0),
                int(total or 0),
                float(speed or 0.0),
                str(ph or ""),
            )
        except Exception:
            pass

    def progress_hook(d):
        if _is_cancelled():
            raise _DownloadCancelled()
        status = d.get("status")
        if status == "downloading":
            total = (
                d.get("total_bytes")
                or d.get("total_bytes_estimate")
                or 0
            )
            _emit(
                "downloading",
                d.get("downloaded_bytes", 0),
                total,
                d.get("speed") or 0.0,
                phase,
            )
        elif status == "finished":
            _emit(
                "segment_done",
                d.get("downloaded_bytes", 0),
                d.get("total_bytes", 0),
                0.0,
                phase,
            )

    ydl_opts = {
        "quiet": True,
        "no_warnings": True,
        "format": str(itag),
        "outtmpl": output_path_template,
        "progress_hooks": [progress_hook],
        "retries": 3,
        "fragment_retries": 3,
        "concurrent_fragment_downloads": 1,
        # Do not attempt to merge — we handle merging in Dart with FFmpeg.
        "merge_output_format": None,
        # Avoid writing sidecar files.
        "noprogress": True,
        "writethumbnail": False,
        "writesubtitles": False,
    }

    try:
        import yt_dlp
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(video_url, download=True)
            # Resolve the final file name yt-dlp actually wrote.
            if info is None:
                return json.dumps({"error": "yt-dlp returned no info"})
            # Single format: info is the format dict itself.
            if "requested_downloads" in info and info["requested_downloads"]:
                final_path = info["requested_downloads"][0].get(
                    "filepath"
                ) or info["requested_downloads"][0].get("_filename")
            else:
                final_path = info.get("_filename") or info.get("filepath")

        if not final_path:
            # Fallback: probe common extensions next to the template.
            import os
            base, _ = os.path.splitext(output_path_template)
            for ext in (".mp4", ".m4a", ".webm", ".mkv", ".opus", ".mp3"):
                candidate = base + ext
                if os.path.exists(candidate):
                    final_path = candidate
                    break

        if not final_path:
            return json.dumps({"error": "File hasil download tidak ditemukan"})

        return json.dumps({"path": final_path})

    except _DownloadCancelled:
        return json.dumps({"error": "cancelled"})
    except Exception as e:
        # yt-dlp wraps our cancellation; detect it as well.
        if isinstance(e.__cause__, _DownloadCancelled) or \
           "cancelled" in str(e).lower():
            return json.dumps({"error": "cancelled"})
        return json.dumps({"error": str(e)})

