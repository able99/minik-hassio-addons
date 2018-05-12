import json
import os

print 'starting'
with open("/data/options.json",'r') as load_f:
  obj = json.load(load_f)
pathbypy = '/share/bypy'
os.system("mkdir -p %s" % (pathbypy))
authCode = obj['authCode']
byBasePath = obj['byBasePath']

if authCode :
  print 'authing...'
  cmd = "echo %s | bypy --config-dir %s list" % ( authCode, pathbypy )
  print cmd, '=>', os.system(cmd)

print 'working...'
for disk in obj['disks']:
  print "disk:"
  print disk
  direction = disk['direction']
  if disk['disabled'] or not disk['pathname'] or not disk['byPathname'] or not (direction == 'syncdown' or direction == 'syncup'):
    print 'skip'
    continue

  src  = byBasePath + disk['byPathname'] if direction == 'syncdown' else disk['pathname'] 
  dest = disk['pathname'] if direction == 'syncdown' else byBasePath + disk['byPathname'] 
  cmd = "bypy --config-dir %s -v -d %s %s %s" % (pathbypy, direction, src, dest)
  print cmd, '=>', os.system(cmd)

print '--all ok--'