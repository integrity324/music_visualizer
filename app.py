from flask import Flask, request, jsonify
import yt_dlp

app = Flask(__name__)

@app.route('/extract', methods=['POST'])
def extract_audio():
    data = request.json
    url = data.get('url')

    ydl_opts = {
        'format': 'bestaudio/best',
        'quiet': True,
        'skip_download': True,
    }

    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            audio_url = info['url']
            title = info.get('title', 'Unknown Title')
            return jsonify({'audio_url': audio_url, 'title': title})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)

