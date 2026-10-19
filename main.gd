extends Node3D

var bike: Node3D
var speed := 0.0
var throttle := false
var braking := false
var left_pressed := false
var right_pressed := false
var wheelie_pressed := false
var hud: Label
var status: Label
var camera_pivot: Node3D

const MAX_SPEED := 25.0
const ACCELERATION := 10.0
const BRAKE_FORCE := 18.0
const DRAG := 2.2
const TURN_SPEED := 1.35

func _ready() -> void:
    make_world()
    make_bike()
    make_camera()
    make_ui()

func _process(delta: float) -> void:
    if throttle:
        speed = minf(speed + ACCELERATION * delta, MAX_SPEED)
    elif braking:
        speed = maxf(speed - BRAKE_FORCE * delta, 0.0)
    else:
        speed = move_toward(speed, 0.0, DRAG * delta)

    var steer := float(right_pressed) - float(left_pressed)
    if speed > 0.15:
        bike.rotation.y -= steer * TURN_SPEED * delta * clampf(speed / 7.0, 0.2, 1.0)

    bike.position += -bike.global_basis.z * speed * delta
    bike.position.x = clampf(bike.position.x, -5.0, 5.0)
    if bike.position.z < -100.0:
        bike.position.z = 8.0

    bike.rotation.z = lerpf(bike.rotation.z, -steer * 0.12, delta * 4.0)
    bike.rotation.x = lerpf(bike.rotation.x, -0.22 if wheelie_pressed and speed > 2.0 else 0.0, delta * 2.0)

    camera_pivot.global_position = camera_pivot.global_position.lerp(bike.global_position + Vector3(0, 2.0, 0), delta * 3.5)
    hud.text = "GRAU BRASILEIRO  |  %03d km/h" % int(speed * 4.0)
    status.text = "EMPINANDO (teste visual)" if wheelie_pressed else "VERSAO 0.1  |  PROTOTIPO"

func make_world() -> void:
    var env_node := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.48, 0.72, 0.92)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.8, 0.8, 0.8)
    env_node.environment = env
    add_child(env_node)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-50, -25, 0)
    sun.light_energy = 1.1
    add_child(sun)

    add_box("Grama", Vector3(0, -0.4, -40), Vector3(70, 0.5, 150), Color(0.18, 0.45, 0.2))
    add_box("Asfalto", Vector3(0, -0.1, -40), Vector3(12, 0.15, 150), Color(0.19, 0.2, 0.22))
    for z in range(-110, 25, 10):
        add_box("Faixa", Vector3(0, 0.0, z), Vector3(0.14, 0.025, 4.0), Color(0.95, 0.9, 0.65))
    add_box("BordaE", Vector3(-6.1, 0.03, -40), Vector3(0.15, 0.08, 150), Color.WHITE)
    add_box("BordaD", Vector3(6.1, 0.03, -40), Vector3(0.15, 0.08, 150), Color.WHITE)
    for z in range(-100, 20, 15):
        add_box("MarcadorE", Vector3(-8.0, 0.4, z), Vector3(0.5, 0.8, 0.5), Color(0.9, 0.25, 0.08))
        add_box("MarcadorD", Vector3(8.0, 0.4, z), Vector3(0.5, 0.8, 0.5), Color(0.9, 0.25, 0.08))

func make_bike() -> void:
    bike = Node3D.new()
    bike.position = Vector3(0, 0.2, 5)
    add_child(bike)
    add_bike_box("Roda traseira", Vector3(0, 0.45, 0.75), Vector3(0.18, 0.85, 0.85), Color(0.04, 0.04, 0.05))
    add_bike_box("Roda dianteira", Vector3(0, 0.45, -0.82), Vector3(0.18, 0.85, 0.85), Color(0.04, 0.04, 0.05))
    add_bike_box("Chassi", Vector3(0, 0.82, 0), Vector3(0.2, 0.18, 1.25), Color(0.85, 0.08, 0.06))
    add_bike_box("Tanque", Vector3(0, 1.08, -0.15), Vector3(0.5, 0.35, 0.55), Color(0.9, 0.08, 0.06))
    add_bike_box("Banco", Vector3(0, 1.15, 0.4), Vector3(0.4, 0.12, 0.5), Color(0.04, 0.04, 0.04))
    add_bike_box("Motor", Vector3(0, 0.7, 0.05), Vector3(0.4, 0.42, 0.45), Color(0.48, 0.5, 0.52))
    add_bike_box("Guidão", Vector3(0, 1.38, -0.58), Vector3(0.8, 0.07, 0.07), Color(0.08, 0.08, 0.08))
    add_bike_box("Piloto", Vector3(0, 1.52, 0.12), Vector3(0.4, 0.52, 0.35), Color(0.08, 0.16, 0.8))
    add_bike_box("Capacete", Vector3(0, 1.94, -0.02), Vector3(0.36, 0.36, 0.36), Color(0.95, 0.65, 0.08))

func make_camera() -> void:
    camera_pivot = Node3D.new()
    camera_pivot.position = Vector3(0, 2.2, 7.0)
    add_child(camera_pivot)
    var cam := Camera3D.new()
    cam.position = Vector3(0, 2.7, 6.5)
    cam.rotation_degrees = Vector3(-12, 0, 0)
    cam.current = true
    camera_pivot.add_child(cam)
    cam.look_at_from_position(cam.global_position, bike.global_position + Vector3(0, 1.0, -3.0), Vector3.UP)

func make_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    hud = Label.new()
    hud.position = Vector2(20, 16)
    hud.add_theme_font_size_override("font_size", 24)
    hud.add_theme_color_override("font_color", Color.WHITE)
    layer.add_child(hud)
    status = Label.new()
    status.position = Vector2(20, 50)
    status.add_theme_font_size_override("font_size", 16)
    status.add_theme_color_override("font_color", Color.WHITE)
    layer.add_child(status)
    hold_button(layer, "◀", Vector2(22, -100), Vector2(76, 72), func(v): left_pressed = v)
    hold_button(layer, "▶", Vector2(106, -100), Vector2(76, 72), func(v): right_pressed = v)
    hold_button(layer, "FREIO", Vector2(-205, -100), Vector2(88, 72), func(v): braking = v)
    hold_button(layer, "ACELERAR", Vector2(-112, -100), Vector2(104, 72), func(v): throttle = v)
    hold_button(layer, "EMPINAR", Vector2(-112, -180), Vector2(104, 64), func(v): wheelie_pressed = v)

func hold_button(layer: CanvasLayer, title: String, offset: Vector2, button_size: Vector2, action: Callable) -> void:
    var b := Button.new()
    b.text = title
    b.size = button_size
    b.anchor_left = 0.0 if offset.x >= 0 else 1.0
    b.anchor_right = 0.0 if offset.x >= 0 else 1.0
    b.anchor_top = 1.0
    b.anchor_bottom = 1.0
    b.position = offset
    b.add_theme_font_size_override("font_size", 17)
    b.button_down.connect(func(): action.call(true))
    b.button_up.connect(func(): action.call(false))
    layer.add_child(b)

func add_box(title: String, pos: Vector3, dimensions: Vector3, color: Color) -> void:
    var instance := MeshInstance3D.new()
    instance.name = title
    var mesh := BoxMesh.new()
    mesh.size = dimensions
    instance.mesh = mesh
    instance.position = pos
    instance.material_override = material(color)
    add_child(instance)

func add_bike_box(title: String, pos: Vector3, dimensions: Vector3, color: Color) -> void:
    var instance := MeshInstance3D.new()
    instance.name = title
    var mesh := BoxMesh.new()
    mesh.size = dimensions
    instance.mesh = mesh
    instance.position = pos
    instance.material_override = material(color)
    bike.add_child(instance)

func material(color: Color) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.8
    return mat
