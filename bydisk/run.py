import json
import os

print 'starting'
with open("/data/options.json",'r') as load_f:
  obj = json.load(load_f)
print 'options:'
print obj

authCode = obj['authCode']

if authCode :
  cmd = "echo %s | bypy list" % ( authCode )
  print cmd
  os.system(cmd)
  cmd = "cp -r ~/.bypy /share/.bypy"
  print cmd
  os.system(cmd)
else :
  cmd = "cp -r /share/.bypy ~/.bypy"
  print cmd
  os.system(cmd)
  byBasePath = obj['byBasePath']

  for disk in obj['disks']:
    print "disk:"
    print disk
    direction = disk['direction']
    if not disk['disabled'] or not disk['pathname'] or not disk['byPathname'] or not (direction == 'syncdown' or direction == 'syncup'):
      continue

    src  = byBasePath + disk['byPathname'] if direction == 'syncdown' else disk['pathname'] 
    dest = disk['pathname'] if direction == 'syncdown' else byBasePath + disk['byPathname'] 
    cmd = "bypy %s %s %s" % (direction, src, dest)

    print cmd
    os.system(cmd)
    print '--ok--'