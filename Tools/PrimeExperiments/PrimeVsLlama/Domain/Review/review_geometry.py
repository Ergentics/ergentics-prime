#!/usr/bin/env python3
import json,struct,math,hashlib
from pathlib import Path
w=Path(__file__).resolve().parents[1];p=w/'GeometryMetal/Live/native';r=json.loads((p/'result.json').read_bytes())
assert r['status']=='PASS' and r['commandBufferStatus']==4 and r['commandBufferError'] is None
assert r['actualSubmittedDispatches']==1 and not r['cpuFallback'] and not r['virtualGPU'] and r['guestRuns']==r['modelRuns']==0
arrays={}
for a in r['artifacts']:
 b=(p/a['path']).read_bytes();assert len(b)==a['content']['byteCount'] and hashlib.sha256(b).hexdigest()==a['content']['sha256']
 k='f' if a['dtype']=='float32_little_endian' else 'd';n=math.prod(a['shape']);v=struct.unpack('<'+str(n)+k,b);assert all(math.isfinite(x) for x in v);arrays[a['path']]=v
assert all(x['rejected'] and x['submittedDispatches']==0 for x in r['invalidInputChecks']) and len(r['invalidInputChecks'])==14
for a,b,name in [('gpu-potential.f32le','cpu-potential.f64le','gpuPotentialVsCPUDirect'),('gpu-gradient.f32le','cpu-gradient.f64le','gpuGradientVsCPUDirect')]:
 maximum=max(abs(x-y) for x,y in zip(arrays[a],arrays[b]));assert maximum==r['comparisons'][name]['maxAbsoluteError']
 assert r['comparisons'][name]['failures']==0
prov=json.loads((w/'GeometryMetal/PROVENANCE.json').read_bytes())
for a in prov['upstreamFiles']:
 b=Path(a['path']).read_bytes();assert len(b)==a['byteCount'] and hashlib.sha256(b).hexdigest()==a['sha256']
controller=json.loads((w/'GeometryMetal/Live/controller/result.json').read_bytes());assert controller['passed'] and controller['exact_reap_count']==1
out={'status':'PASS','pointCount':r['pointCount'],'nodeCount':r['nodeCount'],'actualMetalDispatches':1,'controllerPassed':True,
 'originalGeometrySourcesUnchanged':True,'allSixArraysHashBoundAndFinite':True,'invalidInputsRejected':14,
 'maximumPotentialError':r['comparisons']['gpuPotentialVsCPUDirect']['maxAbsoluteError'],
 'maximumGradientError':r['comparisons']['gpuGradientVsCPUDirect']['maxAbsoluteError'],
 'guestRuns':0,'virtualGPU':False,'modelRuns':0,'limitation':'One bounded host Metal dispatch; no performance or neural knowledge claim.'}
(w/'Review/GEOMETRY-REVIEW.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out))
