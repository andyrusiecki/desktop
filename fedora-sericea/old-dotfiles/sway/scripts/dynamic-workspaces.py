#!/bin/python3

import asyncio
from i3ipc import Event
from i3ipc.aio import Connection

icons = {
    "celluloid": "辶",
    "chromium": "",
    "code": "",
    "code-oss": "",
    "discord": "",
    "firefox": "",
    "kitty": "",
    "mpv": "辶",
    "org.gnome.Nautilus": "",
    "org.gnome.Software": "",
    "slack": "",
    "spotify": "",
    "steam": ""
}

default_icon = ""

async def get_i3():
    return await Connection().connect()

def get_workspaces_from_con(con):
    if con.type == "workspace" and con.name != "__i3_scratch":
        return [ con ]
    
    workspaces = []
    for con in con.nodes:
        workspaces.extend(get_workspaces_from_con(con))
    
    return workspaces

def get_apps(ws): 
    apps = []
    for node in ws.nodes:
        if node.window_class:
            apps.append(node.window_class.lower())
        elif node.app_id:
            apps.append(node.app_id.lower())
        else:
            apps.extend(get_apps(node))
    
    return apps
    
def get_new_workspace_name(ws):
    name = str(ws.num)

    apps = get_apps(ws)

    if len(apps) > 0:
        name += ': '

    apps = []
    for app in get_apps(ws):
        if app in icons:
            apps.append(icons[app])
        else:
            apps.append(default_icon)

    return name + '  '.join(apps)

async def update_workspace_name(i3, ws, new_name):
    reply = await i3.command('rename workspace "' + ws.name + '" to "' + new_name + '"')

    return reply[0]

async def get_workspaces(i3):
    tree = await i3.get_tree()
    return get_workspaces_from_con(tree)

async def update_workspaces(i3):
    print("\nchecking workspaces...")
    workspaces = await get_workspaces(i3)
    
    for ws in workspaces:
        print("workspace " + str(ws.num) + ": " + ' '.join(get_apps(ws)))
        new_name = get_new_workspace_name(ws)

        if ws.name == new_name:
            continue
        
        result = await update_workspace_name(i3, ws, new_name)

        if result.success:
            print(" - update name from \"" + ws.name + "\" to \"" + new_name + "\"")
        else:
            print("- error: " + result.error)

async def on_window_update(i3, e):
    if e.change not in [ "close", "move", "new", "title"]:
        return
    
    return await update_workspaces(i3)

async def on_workspace_update(i3, e):
    if e.change not in [ "init", "move"]:
        return
    
    return await update_workspaces(i3)

async def start_monitor():
    i3 = await get_i3()

    i3.on(Event.WINDOW, on_window_update)
    i3.on(Event.WORKSPACE, on_workspace_update)

    await i3.main()

asyncio.run(start_monitor())
