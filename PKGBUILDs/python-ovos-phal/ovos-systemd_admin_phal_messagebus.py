import sdnotify
from ovos_PHAL.admin import main

n = sdnotify.SystemdNotifier()

def notify_ready():
    n.notify('READY=1')
    print('Startup of Admin service complete')

def notify_stopping():
    n.notify('STOPPING=1')
    print('Stopping Admin service')

main(ready_hook=notify_ready, stopping_hook=notify_stopping)