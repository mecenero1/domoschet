"""Собирает index.html из src/index.html: встраивает картинки как data URI,
чтобы страница открывалась одним файлом без внешних запросов к изображениям."""
import base64, pathlib, re

ROOT = pathlib.Path(__file__).parent
src = (ROOT / 'src' / 'index.html').read_text(encoding='utf-8')

def inline(match):
    path = ROOT / 'assets' / 'img' / match.group(1)
    return 'data:image/webp;base64,' + base64.b64encode(path.read_bytes()).decode()

out = re.sub(r'\.\./assets/img/([a-z0-9\-]+\.webp)', inline, src)
(ROOT / 'index.html').write_text(out, encoding='utf-8')
print(f'index.html: {len(out.encode()) // 1024} КБ')
