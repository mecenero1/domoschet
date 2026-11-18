
// ───── Сцена: макет современного дома на подиуме ─────
#define SUN_DIR vec3(-0.62,0.74,0.40)
#define SUN_COL (vec3(1.0,0.93,0.84)*3.1)
#define SKY_COL (vec3(0.62,0.69,0.78)*0.62)
#define BOUNCE_COL (vec3(0.85,0.78,0.66)*0.22)
#define BACK_COL (vec3(0.9,0.92,1.0)*0.12)
#define HORIZON_COL vec3(0.86,0.86,0.85)
#define ZENITH_COL vec3(0.52,0.62,0.76)
#define GROUND_ENV vec3(0.33,0.31,0.28)
#define ENV_STRENGTH 1.0
#define EXPOSURE 0.92
#define SHADOW_K 9.
#define GROUND_Y -0.62
#define SHADOW_TINT vec3(0.10,0.09,0.08)
#define SHADOW_CENTER vec2(0.,0.75)
#define TMAX 70.
const vec3 CAM_POS=vec3(10.5,8.8,21.5);
const vec3 CAM_TGT=vec3(0.5,1.25,0.6);
const float FOCAL=3.45;

const float HW=2.3, HD=3.5, HE=3.0, HR=5.25;
const vec3 HC=vec3(-1.0,0.,0.);
const vec3 SVC=vec3(3.05,0.,0.3); const vec3 SVH=vec3(1.75,1.5,2.3);

float gableSolid(vec3 q, float w, float d, float he, float hr){
  float b=sdBox(q-vec3(0.,hr*0.5,0.), vec3(w,hr*0.5,d));
  vec3 rp=vec3(0.,hr,0.);
  vec3 nl=normalize(vec3(-(hr-he),w,0.)), nr=normalize(vec3(hr-he,w,0.));
  return max(b,max(dot(q-rp,nl),dot(q-rp,nr)));
}
float recessPrism(vec3 q){
  float g=gableSolid(q, HW-0.38, 20., HE-0.1, HR-0.55);
  return max(g, 0.22-q.y);
}
float roofSlab(vec3 q){
  q.x=abs(q.x);
  float a=atan(HR-HE,HW), c=cos(a), s=sin(a);
  vec2 nR=normalize(vec2(HR-HE,HW));
  vec2 v=q.xy-(vec2(0.,HR)+nR*0.075);
  vec2 l=vec2(v.x*c-v.y*s, v.x*s+v.y*c);
  float L=length(vec2(HW,HR-HE))+0.42;
  return sdRBox(vec3(l.x-(L-0.14)*0.5, l.y, q.z), vec3((L+0.14)*0.5, 0.075, HD+0.32), 0.02);
}
float foliage(vec3 p, vec3 c, vec3 r, float amp){
  float d=sdEll(p-c, r);
  if(d<0.6) d+= amp*(noise3(p*2.4)-0.5) + amp*0.55*(noise3(p*5.7)-0.5) + amp*0.3*(noise3(p*12.5)-0.5);
  return d*0.85;
}

vec2 map(vec3 p){
  // подиум
  vec2 res=vec2(sdRBox(p-vec3(0.,-0.31,0.75), vec3(7.3,0.31,5.8), 0.14), 1.);
  // основной объём
  vec3 q=p-HC;
  float bh=sdBox(q-vec3(0.,HR*0.5,0.), vec3(HW+0.6,HR*0.5+0.4,HD+0.6));
  if(bh<0.5){
    float walls=gableSolid(q, HW, HD, HE, HR);
    float rp=recessPrism(q);
    walls=max(walls, -max(rp, abs(q.z-HD)-0.14));
    res=opU(res, vec2(walls,3.));
    float glass=max(rp, abs(q.z-(HD-0.16))-0.02);
    res=opU(res, vec2(glass,5.));
    // импосты
    vec3 mq=q; mq.x=abs(mq.x);
    float mul=min(sdBox(mq-vec3(0.0,2.,HD-0.11),vec3(0.035,3.,0.05)), sdBox(mq-vec3(1.0,2.,HD-0.11),vec3(0.035,3.,0.05)));
    mul=min(mul, sdBox(q-vec3(0.,2.95,HD-0.11), vec3(3.,0.04,0.05)));
    mul=max(mul, rp);
    res=opU(res, vec2(mul,6.));
    res=opU(res, vec2(roofSlab(q),4.));
    // окно на боковой стене (слева)
    float sw=sdBox(q-vec3(-HW,1.45,-1.2), vec3(0.14,0.75,0.55));
    res.x=max(res.x,-sw);
  } else res=opU(res, vec2(bh,3.));
  // боковой объём с плоской крышей
  vec3 s=p-SVC;
  float bs=sdBox(s-vec3(0.,1.6,0.), SVH+vec3(0.4,0.4,0.4));
  if(bs<0.5){
    float body=sdBox(s-vec3(0.,1.5,0.), SVH);
    float w1=sdBox(s-vec3(-0.1,1.3,SVH.z), vec3(1.25,1.0,0.14));
    float w2=sdBox(s-vec3(SVH.x,1.85,-0.1), vec3(0.14,0.48,1.55));
    body=max(body,-min(w1,w2));
    res=opU(res, vec2(body,7.));
    float g1=sdBox(s-vec3(-0.1,1.3,SVH.z-0.12), vec3(1.25,1.0,0.02));
    float g2=sdBox(s-vec3(SVH.x-0.12,1.85,-0.1), vec3(0.02,0.48,1.55));
    res=opU(res, vec2(min(g1,g2),5.));
    float fr=sdBox(s-vec3(-0.1,1.3,SVH.z-0.09), vec3(0.03,1.0,0.04));
    fr=min(fr, sdBox(s-vec3(SVH.x-0.09,1.85,-0.1), vec3(0.04,0.48,0.03)));
    res=opU(res, vec2(fr,6.));
    res=opU(res, vec2(sdRBox(s-vec3(0.,3.08,0.), vec3(SVH.x+0.12,0.09,SVH.z+0.12),0.02),12.));
  } else res=opU(res, vec2(bs,7.));
  // терраса
  res=opU(res, vec2(sdRBox(p-vec3(-1.0,0.1,4.65), vec3(2.6,0.1,1.05),0.015),8.));
  // лежак и столик на террасе
  res=opU(res, vec2(sdRBox(p-vec3(-2.3,0.42,4.75), vec3(0.42,0.08,0.9),0.06),13.));
  res=opU(res, vec2(sdRBox(p-vec3(-2.3,0.62,4.0), vec3(0.4,0.2,0.1),0.06),13.));
  res=opU(res, vec2(sdRCylY(p-vec3(-1.2,0.42,4.9), 0.32,0.03,0.02),12.));
  res=opU(res, vec2(sdCylY(p-vec3(-1.2,0.3,4.9), 0.03,0.12),6.));
  // деревья
  vec3 t1=vec3(-5.4,0.,-2.7);
  float bt1=sdSph(p-(t1+vec3(0.,3.0,0.)),3.2);
  if(bt1<0.3){
    res=opU(res, vec2(sdCap(p,t1,t1+vec3(0.1,3.6,0.),0.13),11.));
    float f=foliage(p,t1+vec3(0.,4.3,0.),vec3(1.35,1.85,1.35),0.55);
    f=smin(f, foliage(p,t1+vec3(-0.5,3.4,0.4),vec3(1.0,1.0,1.0),0.5),0.5);
    f=smin(f, foliage(p,t1+vec3(0.55,3.6,-0.3),vec3(0.9,1.0,0.9),0.5),0.5);
    res=opU(res, vec2(f*0.8,10.));
  } else res=opU(res, vec2(bt1,10.));
  vec3 t2=vec3(5.9,0.,-3.4);
  float bt2=sdSph(p-(t2+vec3(0.,2.2,0.)),2.6);
  if(bt2<0.3){
    res=opU(res, vec2(sdCap(p,t2,t2+vec3(0.,2.4,0.),0.11),14.));
    float f=foliage(p,t2+vec3(0.,3.0,0.),vec3(1.1,1.35,1.1),0.5);
    f=smin(f, foliage(p,t2+vec3(0.35,2.4,0.3),vec3(0.8,0.75,0.8),0.45),0.4);
    res=opU(res, vec2(f*0.8,10.));
  } else res=opU(res, vec2(bt2,10.));
  // кусты вдоль бокового объёма
  float bb=sdBox(p-vec3(3.3,0.35,3.25), vec3(1.9,0.6,0.7));
  if(bb<0.3){
    float b=foliage(p,vec3(1.95,0.25,3.25),vec3(0.5,0.42,0.45),0.3);
    b=smin(b,foliage(p,vec3(2.8,0.3,3.35),vec3(0.55,0.5,0.5),0.3),0.3);
    b=smin(b,foliage(p,vec3(3.7,0.25,3.25),vec3(0.5,0.42,0.45),0.3),0.3);
    b=smin(b,foliage(p,vec3(4.6,0.3,3.3),vec3(0.55,0.5,0.5),0.3),0.3);
    res=opU(res, vec2(b*0.8,15.));
  } else res=opU(res, vec2(bb,15.));
  return res;
}

Mat getMat(float id, vec3 p, vec3 n){
  Mat m=M(vec3(0.5),0.6,0.,0.5);
  if(id<1.5){
    if(p.y>-0.03 && n.y>0.6){
      float g=fbm(p*1.6), g2=noise3(p*30.);
      float stripe=step(0.5,fract((p.x*0.8+p.z*0.6)/1.3));
      m=M(mix(vec3(0.075,0.14,0.04), vec3(0.16,0.24,0.07), g)*(0.85+0.3*g2)*(0.93+0.12*stripe),0.95,0.,0.2);
      vec3 q=p-HC, s=p-SVC;
      float dh=min(sdBox(q, vec3(HW+0.42,1.,HD+0.42)), sdBox(s, vec3(SVH.x+0.42,1.,SVH.z+0.42)));
      if(dh<0.){ m=M(vec3(0.56,0.54,0.5)*(0.75+0.45*hash13(floor(p*45.))),0.9,0.,0.3); }
    } else m=M(vec3(0.80,0.78,0.74)*(0.94+0.1*noise3(p*5.)),0.65,0.,0.4);
  } else if(id<3.5){
    vec3 q=p-HC;
    float coord = abs(n.z)>0.5 ? q.x : q.z;
    float sb=fract(coord/0.17);
    float groove=smoothstep(0.,0.07,sb)*smoothstep(1.,0.93,sb);
    float grain=noise3(vec3(coord*3.,p.y*0.6,coord*3.)*4.);
    m=M(vec3(0.085,0.08,0.075)*(0.55+0.45*groove)*(0.85+0.3*grain),0.62,0.,0.5);
    if(q.y<0.22) m=M(vec3(0.42,0.41,0.39)*(0.9+0.15*noise3(p*12.)),0.8,0.,0.3);
  } else if(id<4.5){
    vec3 q=p-HC;
    float seam=1.-smoothstep(0.012,0.03,abs(fract(q.z/0.48)-0.5));
    m=M(vec3(0.075,0.078,0.083)+seam*0.05,0.36,0.55,0.5);
  } else if(id<5.5){
    m=M(vec3(0.015,0.02,0.025),0.03,0.,1.7);
    float fl=smoothstep(4.6,0.4,p.y)*(0.75+0.25*smoothstep(2.9,2.6,p.y));
    m.emi=vec3(1.0,0.72,0.45)*0.075*fl;
  } else if(id<6.5){
    m=M(vec3(0.04,0.04,0.042),0.35,0.3,0.5);
  } else if(id<7.5){
    vec3 s=p-SVC;
    float sb=fract(p.y/0.13);
    float groove=smoothstep(0.,0.08,sb)*smoothstep(1.,0.92,sb);
    float along = abs(n.z)>0.5 ? s.x : s.z;
    float grain=noise3(vec3(along*1.5,p.y*25.,along*1.5));
    float plank=hash12(vec2(floor(p.y/0.13), floor(along/1.6)));
    vec3 wood=mix(vec3(0.60,0.42,0.27), vec3(0.72,0.53,0.35), plank)*(0.82+0.3*grain);
    m=M(wood*(0.6+0.4*groove),0.6,0.,0.5);
    if(p.y<0.2) m=M(vec3(0.42,0.41,0.39),0.8,0.,0.3);
  } else if(id<8.5){
    float sb=fract(p.z/0.15);
    float groove=smoothstep(0.,0.08,sb)*smoothstep(1.,0.92,sb);
    float plank=hash12(vec2(floor(p.z/0.15), floor(p.x/1.8+fract(floor(p.z/0.15)*0.37))));
    m=M(mix(vec3(0.46,0.33,0.22),vec3(0.56,0.41,0.28),plank)*(0.6+0.4*groove)*(0.88+0.2*noise3(vec3(p.x*2.,p.y,p.z*40.))),0.55,0.,0.5);
  } else if(id<10.5){
    float g=noise3(p*3.2), g2=noise3(p*13.);
    m=M(mix(vec3(0.05,0.12,0.035), vec3(0.17,0.27,0.07), g)*(0.65+0.6*g2),0.75,0.,0.3);
  } else if(id<11.5){
    float mark=smoothstep(0.62,0.72,noise3(vec3(p.x*9.,p.y*16.,p.z*9.)));
    m=M(mix(vec3(0.86,0.84,0.79), vec3(0.08,0.07,0.06), mark),0.7,0.,0.4);
  } else if(id<12.5){
    m=M(vec3(0.055,0.055,0.06),0.5,0.,0.5);
  } else if(id<13.5){
    m=M(vec3(0.84,0.81,0.75)*(0.92+0.1*noise3(p*20.)),0.85,0.,0.3);
  } else if(id<14.5){
    m=M(vec3(0.22,0.15,0.10)*(0.8+0.3*noise3(p*vec3(20.,4.,20.))),0.85,0.,0.3);
  } else if(id<9.5){
    m=M(vec3(0.62,0.61,0.58)*(0.9+0.15*noise3(p*14.)),0.8,0.,0.35);
  } else {
    float g=noise3(p*4.), g2=noise3(p*15.);
    m=M(mix(vec3(0.06,0.13,0.04), vec3(0.16,0.25,0.07), g)*(0.65+0.6*g2),0.75,0.,0.3);
  }
  return m;
}
