import asyncio, base64, sys, time, json, pathlib
from playwright.async_api import async_playwright

HERE = pathlib.Path(__file__).parent
HTML = """<!doctype html><canvas id=c></canvas><script>
window.render = async (src, W, H, spp, tile) => {
  const cv=document.getElementById('c'); cv.width=W; cv.height=H;
  const gl=cv.getContext('webgl2',{preserveDrawingBuffer:true,premultipliedAlpha:false,antialias:false,alpha:true});
  const vs=`#version 300 es
  in vec2 p; void main(){ gl_Position=vec4(p,0.,1.); }`;
  function sh(t,s){ const o=gl.createShader(t); gl.shaderSource(o,s); gl.compileShader(o); if(!gl.getShaderParameter(o,gl.COMPILE_STATUS)) throw new Error(gl.getShaderInfoLog(o)); return o; }
  const pr=gl.createProgram(); gl.attachShader(pr,sh(gl.VERTEX_SHADER,vs)); gl.attachShader(pr,sh(gl.FRAGMENT_SHADER,src)); gl.linkProgram(pr);
  if(!gl.getProgramParameter(pr,gl.LINK_STATUS)) throw new Error(gl.getProgramInfoLog(pr));
  gl.useProgram(pr);
  const b=gl.createBuffer(); gl.bindBuffer(gl.ARRAY_BUFFER,b); gl.bufferData(gl.ARRAY_BUFFER,new Float32Array([-1,-1,3,-1,-1,3]),gl.STATIC_DRAW);
  const loc=gl.getAttribLocation(pr,'p'); gl.enableVertexAttribArray(loc); gl.vertexAttribPointer(loc,2,gl.FLOAT,false,0,0);
  gl.uniform2f(gl.getUniformLocation(pr,'uRes'),W,H); gl.uniform1i(gl.getUniformLocation(pr,'uSpp'),spp);
  gl.viewport(0,0,W,H); gl.disable(gl.BLEND); gl.clearColor(0,0,0,0); gl.clear(gl.COLOR_BUFFER_BIT); gl.enable(gl.SCISSOR_TEST);
  const px=new Uint8Array(4);
  for(let y=0;y<H;y+=tile) for(let x=0;x<W;x+=tile){
    gl.scissor(x,y,Math.min(tile,W-x),Math.min(tile,H-y)); gl.drawArrays(gl.TRIANGLES,0,3);
    gl.readPixels(x,y,1,1,gl.RGBA,gl.UNSIGNED_BYTE,px);
    await new Promise(r=>setTimeout(r,0));
  }
  return cv.toDataURL('image/png');
};
</script>"""

async def main(jobs):
    head = (HERE/'common_head.glsl').read_text()
    tail = (HERE/'common_main.glsl').read_text()
    async with async_playwright() as p:
        b = await p.chromium.launch(executable_path='/usr/bin/google-chrome',
              args=['--no-sandbox','--ignore-gpu-blocklist','--use-angle=swiftshader','--enable-unsafe-swiftshader','--disable-gpu-watchdog'])
        pg = await b.new_page(); await pg.set_content(HTML)
        for scene, W, H, spp, out in jobs:
            name,_,var=scene.partition('@')
            sc=('#define VARIANT '+var+'\n' if var else '')+(HERE/f'{name}.glsl').read_text().replace('#include studio',(HERE/'studio.glsl').read_text())
            src = head + sc + tail
            t = time.time()
            url = await pg.evaluate('([s,W,H,n,t])=>window.render(s,W,H,n,t)', [src, W, H, spp, 64])
            (HERE/out).write_bytes(base64.b64decode(url.split(',')[1]))
            print(f'{scene} {W}x{H} spp={spp*spp} -> {out} in {time.time()-t:.1f}s', flush=True)
        await b.close()

if __name__ == '__main__':
    jobs = json.loads(sys.argv[1])
    asyncio.run(main(jobs))
