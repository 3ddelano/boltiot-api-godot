extends HTTPRequest
class_name Boltiot

# -----
# Constants
# -----
var BASE_URL = "https://cloud.boltiot.com/remote"

var URLS = {
	"digital_write" : "/digitalWrite?pin=%s&state=%s&deviceName=%s",
	"digital_multi_write" : "/digitaMultilWrite?pins=%s&states=%s&deviceName=%s",
	"digital_read" : "/digitalRead?pin=%s&deviceName=%s",
	"digital_multi_read" : "/digitalMultiRead?pins=%s&deviceName=%s",
	"analog_write" : "/analogWrite?pin=%s&value=%s&deviceName=%s",
	"analog_multi_write" : "/analogMultiWrite?pins=%s&values=%s&deviceName=%s",
	"analog_read" : "/analogRead?pin=%s&deviceName=%s",
	"analog_multi_read" : "/analogMultiRead?pins=%s&deviceName=%s",

	"serial_begin" : "/serialBegin?baud=%s&deviceName=%s",
	"serial_write" : "/serialWrite?data=%s&deviceName=%s",
	"serial_read" : "/serialRead?till=%s&deviceName=%s",
	"serial_write_read": "/serialWR?data=%s&till=%s&deviceName=%s",

	"servo_write": "/servoWrite?pin=%s&value=%s&deviceName=%s",
	"servo_multi_write": "/servoMultiWrite?pins=%s&values=%s&deviceName=%s",

	"version" : "/version?deviceName=%s",
	"restart" : "/restart?deviceName=%s",
	"is_online" : "/isOnline?deviceName=%s",

	"get_devices" : "/getDevices",
	"fetch_data" : "/fetchData?deviceName=%s",
}

# -----
# Private variables
# -----
var _api_key
var _device_name

# -----
# Built-in virtual _ready method
# -----
func _ready():
	pass


# -----
# Public methods
# -----
func setup(p_apikey: String, p_devicename: String):
	_api_key = p_apikey
	_device_name = p_devicename

func digital_write(pin: int, state: bool):
	return digital_multi_write([pin], [state])

func digital_multi_write(pins: Array, states: Array):
	assert(pins.size() == states.size(), "digital_multi_write Error: pins and states must be Array of same size.")
	var _pins = PoolStringArray(pins).join(",")

	# Convert state to either HIGH or LOW
	for i in range(len(states)):
		states[i] = "HIGH" if states[i] else "LOW"
	var _states = PoolStringArray(states).join(",")

	var url = URLS.digital_multi_write
	if pins.size() == 1:
		url = URLS.digital_write
	return _make_request(url % [_pins, _states, _device_name])

func digital_read(pin: int):
	return digital_multi_read([pin])

func digital_multi_read(pins: Array):
	var _pins = PoolStringArray(pins).join(",")
	var url = URLS.digital_multi_read
	if pins.size() == 1:
		url = URLS.digital_read
	return _make_request(url % [_pins, _device_name])

func analog_write(pin: int, state: bool):
	return analog_multi_write([pin], [state])

func analog_multi_write(pins: Array, states: Array):
	assert(pins.size() == states.size(), "analog_multi_write Error: pins and states must be Array of same size.")
	var _pins = PoolStringArray(pins).join(",")

	# Convert state to either HIGH or LOW
	for i in range(len(states)):
		states[i] = "HIGH" if states[i] else "LOW"
	var _states = PoolStringArray(states).join(",")

	var url = URLS.analog_multi_write
	if pins.size() == 1:
		url = URLS.analog_write
	return _make_request(url % [_pins, _states, _device_name])

func analog_read(pin: String = "A0"):
	return _make_request(URLS.analog_read % [pin, _device_name], false)


func serial_begin(baud: int = 9600):
	return _make_request(URLS.serial_begin % [baud, _device_name])

func serial_write(data: String):
	return _make_request(URLS.serial_write % [data, _device_name])

func serial_read(till = null):
	var url = URLS.serial_read
	if till == null:
		url = url.replace("till=%s&", "")
		return _make_request(url % [_device_name])
	return _make_request(url % [till, _device_name])

func serial_write_read(data: String, till = null):
	var url = URLS.serial_write_read
	if till == null:
		url = url.replace("till=%s&", "")
		return _make_request(url % [data, _device_name])
	return _make_request(URLS.serial_write_read % [data, till, _device_name])


func get_version():
	return _make_request(URLS.version % [_device_name])

func get_device_status():
	return _make_request(URLS.is_online % [_device_name])
	
func get_devices():
	return _make_request(URLS.get_devices)

func restart():
	return _make_request(URLS.restart % [_device_name])


func servo_write(pin: int, state: bool):
	return servo_multi_write([pin], [state])

func servo_multi_write(pins: Array, states: Array):
	assert(pins.size() == states.size(), "servo_multi_write Error: pins and states must be Array of same size.")
	var _pins = PoolStringArray(pins).join(",")

	# Convert state to either HIGH or LOW
	for i in range(len(states)):
		states[i] = "HIGH" if states[i] else "LOW"
	var _states = PoolStringArray(states).join(",")

	var url = URLS.servo_multi_write
	if pins.size() == 1:
		url = URLS.servo_write
	return _make_request(url % [_pins, _states, _device_name])

func fetch_data():
	return _make_request(URLS.fetch_data % _device_name)


# -----
# Private methods
# -----

func _make_request(slug: String, format_to_bool = true):
	var url = BASE_URL + "/" + _api_key + slug
	var error = request(url, ["Cache-Control: no-cache"], false, HTTPClient.METHOD_GET)
	print(url)

	if error != OK:
		push_error("HTTPRequest request error code: " + String(error))
		return _make_error("HTTP_ERROR: " + String(error))

	var response = yield(self, "request_completed")

	# Handle various non-successfull errors
	if response[0] == RESULT_TIMEOUT:
		push_error("HTTPRequest Error: RESULT_TIMEOUT")
		return _make_error("RESULT_TIMEOUT")

	if response[0] in [RESULT_CANT_CONNECT, RESULT_CONNECTION_ERROR, RESULT_CANT_RESOLVE]:
		push_error("HTTPRequest  Error: CONNECTION_ERROR")
		return _make_error("RESULT_CONNECTION_ERROR")

	if not response[0] == HTTPRequest.RESULT_SUCCESS:
		push_error("HTTPRequest Result error: Code " + String(response[0]))
		return _make_error("RESULT_ERROR: " + String(response[0]))

	var body = response[3].get_string_from_utf8()
	var parsed = JSON.parse(body)
	if response[1] >= 200 and response[1] <= 299: # Got success response code
		if parsed.error == OK:
			var result = parsed.result

			# Parse the API response booleans
			if result.has("success"):
				if result.success == 1:
					result.success = true
					if format_to_bool:
						result.value = true if result.value == "1" else false
				else:
					result.success = false
			return result
		else:
			push_error("HTTPRequest response JSON parse error: " + parsed.error_line + ": " + parsed.error_string)
			# TODO: return error here
			return _make_error("JSON_ERROR: " + parsed.error_line + ": " + parsed.error_string)
	else:
		push_error("HTTPRequest error: Response code = " + String(response[1]))
		# TODO: return error here
		return _make_error("HTTPREQUEST_RESPONSE_CODE: " + String(response[1]))

func _make_error(msg: String) -> Dictionary:
	return {
		"success": false,
		"value": msg
	}
