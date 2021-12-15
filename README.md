Boltiot API Wrapper for Godot
=========================================

### Control your Boltiot device from Godot
> ##### See [Documentation](#documentation)

<img height="300" src="https://cdn.discordapp.com/attachments/360062738615107605/920721792992161812/boltiot-godot-logo.png">
<br>
<img alt="Godot3" src="https://img.shields.io/badge/-Godot 3.x-478CBF?style=for-the-badge&logo=godotengine&logoWidth=20&logoColor=white" />

Features
--------------

- Supports all features of [Boltiot API](https://docs.boltiot.com/docs) Free and Pro plans

Installation
--------------

This is a regular plugin for Godot.
Copy the contents of `addons/boltiot-api` into the `addons/` folder in the same directory as your project, and activate it in your project settings.

> Note: You will need a valid API key from [Boltiot Cloud API](https://cloud.boltiot.com/api)


Getting Started
----------

1. After activating the plugin. There will be a new `Boltiot` node added to Godot.
Click on any node in the scene tree for example `Root` and add the `Boltiot` node as a child.

2. Attach a script to the `Root` node.

```GDScript
extends Node2D

func _ready():
	var bolt = $Boltiot

    # Make sure to keep your API key secret
	bolt.setup("<YOUR_API_KEY>", "<YOUR_DEVICE_ID>")
	
    # Now you can run any of the Bolt API commands
    # Make sure to use yield() on every command
    var response = yield(bolt.digital_read(1), "completed")
    print(response)
```

----------



### Support the Development
<a href="https://www.buymeacoffee.com/3ddelano" target="_blank"><img height="36" src="https://cdn.buymeacoffee.com/buttons/v2/default-red.png" alt="Buy Me A Coffee" ></a>
<br>For queries/suggestions/bugs join Discord server: [3ddelano Cafe](https://discord.gg/FZY9TqW)

----------

This project is not affiated with Boltiot Cloud or Inventrom Private Limited. 

----------

# Documentation

> # Class: Boltiot
##### Inherits: [HTTPRequest](https://docs.godotengine.org/en/3.3/classes/class_httprequest.html)
```
The main Node which interacts with the Boltiot Cloud API
```

All method other than `Boltiot.setup()` return a `Dictionary` with the following keys:
```GDScript
{
    "success": bool,
    ...additional keys like value, data
}
```

Method other than `Boltiot.setup()` are async which means you should use `yield(method, "completed")` in order to get the result. 

## Methods (Refer to [Boltiot API Docs](https://docs.boltiot.com/docs/introduction) for more details)
| Returns    | Definition                                                 | Is Async |
| ---------- | ---------------------------------------------------------- | -------- |
|            | **GPIO Methods**                                           |          |
| void       | setup(api_key: String, device_id: String)                  | No       |
| Dictionary | digital_write(pin: int, state: bool)                       | Yes      |
| Dictionary | digital_multi_write(pins: Array[int], states: Array[bool]) | Yes      |
| Dictionary | digital_read(pin: int)                                     | Yes      |
| Dictionary | digital_multi_read(pins: Array[int])                       | Yes      |
| Dictionary | analog_write(pin: int, state: bool)                        | Yes      |
| Dictionary | analog_multi_write(pins: Array[int], states: Array[int])   | Yes      |
| Dictionary | analog_read(pin: String = "A0")                            | Yes      |
|            | **UART Methods**                                           |          |
| Dictionary | serial_begin(baud: int = 9600)                             | Yes      |
| Dictionary | serial_write(data: String)                                 | Yes      |
| Dictionary | serial_read(till?: int)                                    | Yes      |
| Dictionary | serial_write_read(data: String, till?: int)                | Yes      |
| Dictionary | serial_read(till?: int)                                    | Yes      |
| Dictionary | serial_read(till?: int)                                    | Yes      |
|            | **Utility Methods**                                        |          |
| Dictionary | get_version()                                              | Yes      |
| Dictionary | get_device_status()                                        | Yes      |
| Dictionary | get_devices()                                              | Yes      |
| Dictionary | restart()                                                  | Yes      |
|            | **Pro Methods**                                            |          |
| Dictionary | servo_write(pin: int, state: bool)                         | Yes      |
| Dictionary | servo_multi_write(pins: Array[int], states: Array[bool])   | Yes      |
| Dictionary | fetch_data()                                               | Yes      |
