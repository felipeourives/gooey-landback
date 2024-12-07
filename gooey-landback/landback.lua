local gooey = require "gooey.gooey"
local utils = require "gooey.themes.utils"

local M = gooey.create_theme()

local BUTTON_PRESSED = hash("button_pressed")
local BUTTON_OVER = hash("button_over")
local BUTTON_NORMAL = hash("button_normal")
local BUTTON_PRESSED_COLOR = vmath.vector4(1.,1.,1., 1)
local BUTTON_OVER_COLOR = vmath.vector4(1.,0.91,0.549, 1)
local BUTTON_NORMAL_COLOR = vmath.vector4(0.408,0.533,0.533,1)

local CHEKCKBOX_PRESSED = hash("checkbox_pressed")
local CHEKCKBOX_CHECKED_NORMAL = hash("checkbox_checked_normal")
local CHEKCKBOX_CHECKED_PRESSED = hash("checkbox_checked_pressed")
local CHEKCKBOX_CHECKED_SELECTED = hash("checkbox_checked_selected")
local CHEKCKBOX_NORMAL = hash("checkbox_normal")
local CHEKCKBOX_NORMAL_SELECTED = hash("checkbox_normal_selected")

local RADIO_PRESSED = hash("radio_pressed")
local RADIO_CHECKED_PRESSED = hash("radio_checked_pressed")
local RADIO_CHECKED_NORMAL = hash("radio_checked_normal")
local RADIO_CHECKED_SELECTED = hash("radio_checked_selected")
local RADIO_NORMAL = hash("radio_normal")
local RADIO_NORMAL_SELECTED = hash("radio_normal_selected")

local LISTITEM_SELECTED = hash("button_pressed")
local LISTITEM_PRESSED = hash("button_pressed")
local LISTITEM_OVER = hash("button_normal")
local LISTITEM_NORMAL = hash("button_normal")

local TAB_SELECTED = hash("button_normal")
local TAB_PRESSED = hash("button_normal")
local TAB_OVER = hash("button_over")
local TAB_NORMAL = hash("button2_normal")

M.fields = {}
M.list_model_tabs = {}
M.fields_by_index = {}
M.field_focused_index = nil
M.field_focused_key = nil

function M.unfocus_field(field_id)	

	local field = M.fields[M.current_group][field_id]

	if field == nil then
		return nil
	end

	if field.node_main ~= nil then
		gui.play_flipbook(gui.get_node(field.node_main.id), field.node_main.normal)
	end

	if field.node_second ~= nil then
		gui.set_color(gui.get_node(field.node_second.id), field.node_second.normal)
	end
end

function M.focus_field(field_id)

	local field = M.fields[M.current_group][field_id]

	if field == nil then
		return nil
	end

	if field.node_main ~= nil then
		gui.play_flipbook(gui.get_node(field.node_main.id), field.node_main.selected)
	end

	if field.node_second ~= nil then
		gui.set_color(gui.get_node(field.node_second.id), field.node_second.selected)
	end

	M.field_focused_key = field_id
end

function M.focused_field_enter()

	local field = M.fields[M.current_group][M.field_focused_key]

	if field == nil then
		return nil
	end

	local fn = field.fn

	utils.shake(field.obj.node, vmath.vector3(1))

	if field.type == "checkbox" then
		local obj = M.checkbox(field.field_id)
		obj.set_checked(not obj.checked)

	elseif field.type == "radio" then
		local obj = M.radio(field.field_id, field.group_id)
		obj.set_selected(true)
		gooey.radiogroup(field.group_id)

	elseif field.type == "tab" then
		M.list_model_tabs[M.current_group][field.list_id].selected_tab = M.field_focused_key
		M.model_tabs(field.list_id, M.list_model_tabs[M.current_group][field.list_id].data)
	end

	if fn ~= nil then
		fn(field.obj)
	end

	M.focus_field(M.field_focused_key)
	M.fields[M.current_group] = {}
end

function M.next_field()

	if M.field_focused_index == nil or #M.fields_by_index[M.current_group] == M.field_focused_index then
		M.field_focused_index = 1
	else 
		M.field_focused_index = M.field_focused_index + 1
	end

	local field_key = M.fields_by_index[M.current_group][M.field_focused_index]
	M.focus_field(field_key)
end

function M.previous_field()

	if M.field_focused_index == nil or M.field_focused_index == 0 then
		M.field_focused_index = #M.fields_by_index[M.current_group] 
	else 
		M.field_focused_index = M.field_focused_index - 1
	end

	local field_key = M.fields_by_index[M.current_group] [M.field_focused_index]
	M.focus_field(field_key)
end

local function refresh_button(button)

	local button_id = gui.get_id(button.node)
	local field_id = M.fields[M.current_group][button_id].field_id

	if button.pressed_now or button.released_now then
		utils.shake(button.node, vmath.vector3(1))
	end

	if button.pressed then
		gui.set_color(gui.get_node(field_id .. "/label"), BUTTON_PRESSED_COLOR)
		gui.play_flipbook(button.node, BUTTON_PRESSED)

	elseif button.over then

		gui.set_color(gui.get_node(field_id .. "/label"), BUTTON_OVER_COLOR)
		gui.play_flipbook(button.node, BUTTON_OVER)
	else

		gui.set_color(gui.get_node(field_id .. "/label"), BUTTON_NORMAL_COLOR)
		gui.play_flipbook(button.node, BUTTON_NORMAL)
	end
end

function M.button(node_id, action_id, action, fn)
	local field_key = hash(node_id .. "/bg")

	if M.fields[M.current_group][field_key] == nil then

		M.fields[M.current_group][field_key] = {}
		M.fields[M.current_group][field_key].field_id = node_id
		M.fields[M.current_group][field_key].type = "button"
		M.fields[M.current_group][field_key].node_main = {}
		M.fields[M.current_group][field_key].node_main.id = node_id .. "/bg"
		M.fields[M.current_group][field_key].node_main.normal = BUTTON_NORMAL
		M.fields[M.current_group][field_key].node_main.selected = BUTTON_OVER
		M.fields[M.current_group][field_key].node_second = {} 
		M.fields[M.current_group][field_key].node_second. id = node_id .. "/label"
		M.fields[M.current_group][field_key].node_second.normal = BUTTON_NORMAL_COLOR
		M.fields[M.current_group][field_key].node_second.selected = BUTTON_OVER_COLOR

		table.insert(M.fields_by_index[M.current_group] , field_key)
	end

	local field = gooey.button(field_key, action_id, action, fn, refresh_button)
	M.fields[M.current_group][field_key].obj = field
	M.fields[M.current_group][field_key].fn = fn

	return field
end

local function refresh_checkbox(checkbox)

	local field_key = gui.get_id(checkbox.node)
	M.fields[M.current_group][field_key].checked = false
	M.fields[M.current_group][field_key].node_main.normal = CHEKCKBOX_NORMAL
	M.fields[M.current_group][field_key].node_main.selected = CHEKCKBOX_NORMAL_SELECTED

	if checkbox.pressed_now or checkbox.released_now then
		utils.shake(checkbox.node, vmath.vector3(1))
	end

	if checkbox.pressed and not checkbox.checked then
		gui.play_flipbook(checkbox.node, CHEKCKBOX_PRESSED)
	elseif checkbox.pressed and checkbox.checked then
		gui.play_flipbook(checkbox.node, CHEKCKBOX_CHECKED_PRESSED)
	elseif checkbox.checked then
		M.fields[M.current_group][field_key].checked = true
		M.fields[M.current_group][field_key].node_main.normal = CHEKCKBOX_CHECKED_NORMAL
		M.fields[M.current_group][field_key].node_main.selected = CHEKCKBOX_CHECKED_SELECTED
		gui.play_flipbook(checkbox.node, CHEKCKBOX_CHECKED_NORMAL)
	else
		gui.play_flipbook(checkbox.node, CHEKCKBOX_NORMAL)
	end
end

function M.checkbox(node_id, action_id, action, fn)
	local field_key = hash(node_id .. "/box")

	if M.fields[M.current_group][field_key] == nil then
		M.fields[M.current_group][field_key] = {}
		M.fields[M.current_group][field_key].field_id = node_id
		M.fields[M.current_group][field_key].type = "checkbox"
		M.fields[M.current_group][field_key].node_main = {}
		M.fields[M.current_group][field_key].node_main.id = node_id .. "/box"
		M.fields[M.current_group][field_key].node_main.normal = CHEKCKBOX_NORMAL
		M.fields[M.current_group][field_key].node_main.selected = CHEKCKBOX_NORMAL_SELECTED

		table.insert(M.fields_by_index[M.current_group], field_key)
	end

	local field = gooey.checkbox(field_key, action_id, action, fn, refresh_checkbox)
	M.fields[M.current_group][field_key].obj = field
	M.fields[M.current_group][field_key].fn = fn

	return field
end

local function refresh_radiobutton(radio)

	local field_key = gui.get_id(radio.node)
	M.fields[M.current_group][field_key].checked = false
	M.fields[M.current_group][field_key].node_main.normal = RADIO_NORMAL
	M.fields[M.current_group][field_key].node_main.selected = RADIO_NORMAL_SELECTED

	if radio.pressed_now or radio.released_now then
		utils.shake(radio.node, vmath.vector3(1))
	end

	if radio.pressed and not radio.selected then
		gui.play_flipbook(radio.node, RADIO_PRESSED)
	elseif radio.pressed and radio.selected then
		gui.play_flipbook(radio.node, RADIO_CHECKED_PRESSED)
	elseif radio.selected then
		M.fields[M.current_group][field_key].checked = true
		M.fields[M.current_group][field_key].node_main.normal = RADIO_CHECKED_NORMAL
		M.fields[M.current_group][field_key].node_main.selected = RADIO_CHECKED_SELECTED
		gui.play_flipbook(radio.node, RADIO_CHECKED_NORMAL)
	else
		gui.play_flipbook(radio.node, RADIO_NORMAL)
	end
end

function M.radiogroup(group_id, action_id, action, fn)
	return gooey.radiogroup(group_id, action_id, action, fn)
end

function M.radio(node_id, group_id, action_id, action, fn)
	local field_key = hash(node_id .. "/button")

	if M.fields[M.current_group][field_key] == nil then
		M.fields[M.current_group][field_key] = {}
		M.fields[M.current_group][field_key].field_id = node_id
		M.fields[M.current_group][field_key].type = "radio"
		M.fields[M.current_group][field_key].node_main = {}
		M.fields[M.current_group][field_key].node_main.id = node_id .. "/button"
		M.fields[M.current_group][field_key].node_main.normal = RADIO_NORMAL
		M.fields[M.current_group][field_key].node_main.selected = RADIO_NORMAL_SELECTED

		table.insert(M.fields_by_index[M.current_group], field_key)
	end

	local field = gooey.radio(field_key, group_id, action_id, action, fn, refresh_radiobutton)
	M.fields[M.current_group][field_key].obj = field
	M.fields[M.current_group][field_key].group_id = group_id
	M.fields[M.current_group][field_key].fn = fn

	return field
end

local function refresh_input(input, config, node_id)
	local cursor = gui.get_node(node_id .. "/cursor")
	if input.selected then
		gui.set_enabled(cursor, true)
		gui.set_position(cursor, vmath.vector3(25 + input.total_width, 0, 0))
		gui.cancel_animation(cursor, gui.PROP_COLOR)
		gui.set_color(cursor, vmath.vector4(1))
		gui.animate(cursor, gui.PROP_COLOR, BUTTON_NORMAL_COLOR, gui.EASING_INSINE, 0.8, 0, nil, gui.PLAYBACK_LOOP_PINGPONG)
	else
		gui.set_enabled(cursor, false)
		gui.cancel_animation(cursor, gui.PROP_COLOR)
	end
end

function M.input(node_id, keyboard_type, action_id, action, config)
	return gooey.input(node_id .. "/text", keyboard_type, action_id, action, config, function(input)
		refresh_input(input, config, node_id)
	end)
end

local function update_listitem(list, item)
	local pos = gui.get_position(item.root)
	local text_color = BUTTON_NORMAL_COLOR
	if item == list.selected_item then
		pos.x = 4
		gui.play_flipbook(item.root, LISTITEM_PRESSED)
		text_color = BUTTON_PRESSED_COLOR
	elseif item == list.pressed_item then
		pos.x = 1
		gui.play_flipbook(item.root, LISTITEM_SELECTED)
		text_color = BUTTON_PRESSED_COLOR
	elseif item == list.over_item_now then
		pos.x = 1
		gui.play_flipbook(item.root, LISTITEM_OVER)
	elseif item == list.out_item_now then
		pos.x = 0
		gui.play_flipbook(item.root, LISTITEM_NORMAL)
	elseif item ~= list.over_item then
		pos.x = 0
		gui.play_flipbook(item.root, LISTITEM_NORMAL)
	end

	gui.set_color(item.nodes[hash(list.id .. "/listitem_text")], text_color)
	gui.set_position(item.root, pos)
end

local function update_static_list(list)
	for _,item in ipairs(list.items) do
		update_listitem(list, item)
	end
end

function M.static_list(list_id, item_ids, action_id, action, config, fn)
	return gooey.static_list(root_id, list_id .. "/stencil", item_ids, action_id, action, config, fn, update_static_list)
end

local function update_dynamic_list(list)
	for _,item in ipairs(list.items) do
		update_listitem(list, item)
		gui.set_text(item.nodes[hash(list.id .. "/listitem_text")], tostring(item.data or "-"))
	end
end

function M.dynamic_list(list_id, data, action_id, action, config, fn)
	return gooey.dynamic_list(list_id, list_id .. "/stencil", list_id .. "/listitem_bg", data, action_id, action, config, fn, update_dynamic_list)
end

function M.group(id, fn)
	M.current_group = id
	M.fields[M.current_group] = {}
	M.fields_by_index[M.current_group] = {}
	return gooey.group(id, fn)
end

local function update_tab(list, item, index)

	if item.data == nil then
		return nil
	end

	local tab_node_id = list.id .. "/" .. item.data

	gui.set_text(item.nodes[hash(list.id .. "/label")], tostring(M.fields[M.current_group][tab_node_id].label or "-"))

	local pos = gui.get_position(item.root)
	local text_color = nil
	
	pos.x = item.size.x * index + 14 + item.size.x/2

	if index == 0 then
		pos.x = item.size.x/2
	end

	local content_node = nil
	local enable_content_node = false

	if M.fields[M.current_group][tab_node_id] ~= nil and M.fields[M.current_group][tab_node_id].content_id ~= nil then
		content_node = gui.get_node(M.fields[M.current_group][tab_node_id].content_id )
	end

	if tab_node_id == M.list_model_tabs[M.current_group][list.id].selected_tab then
		gui.play_flipbook(item.root, TAB_PRESSED)
		text_color = BUTTON_NORMAL_COLOR
		enable_content_node = true
	elseif item == list.pressed_item then
		M.list_model_tabs[M.current_group][list.id].selected_tab = tab_node_id
		gui.play_flipbook(item.root, TAB_SELECTED)
		utils.shake(item.root, vmath.vector3(1))
		text_color = BUTTON_NORMAL_COLOR
	elseif item == list.over_item_now then
		gui.play_flipbook(item.root, TAB_OVER)
		text_color = BUTTON_OVER_COLOR
	elseif item == list.out_item_now then
		gui.play_flipbook(item.root, TAB_NORMAL)
		text_color = BUTTON_PRESSED_COLOR
	elseif item ~= list.over_item then
		gui.play_flipbook(item.root, TAB_NORMAL)
		text_color = BUTTON_PRESSED_COLOR
	end

	if content_node ~= nil then
		gui.set_enabled(content_node, enable_content_node)
	end

	if text_color ~= nil then
		gui.set_color(item.nodes[hash(list.id .. "/label")], text_color)
	end

	if M.fields[M.current_group][tab_node_id].node_main == nil then
		M.fields[M.current_group][tab_node_id].node_main = {}
		M.fields[M.current_group][tab_node_id].node_main.id = gui.get_id(item.root)
		M.fields[M.current_group][tab_node_id].node_main.normal = TAB_NORMAL
		M.fields[M.current_group][tab_node_id].node_main.selected = TAB_OVER
		M.fields[M.current_group][tab_node_id].node_second = {} 
		M.fields[M.current_group][tab_node_id].node_second.id = gui.get_id(item.nodes[hash(list.id .. "/label")])
		M.fields[M.current_group][tab_node_id].node_second.normal = BUTTON_NORMAL_COLOR
		M.fields[M.current_group][tab_node_id].node_second.selected = BUTTON_OVER_COLOR
		M.fields[M.current_group][tab_node_id].node_main.id = gui.get_id(item.root)

		M.fields[M.current_group][tab_node_id].obj = {}
		M.fields[M.current_group][tab_node_id].obj.node = item.root
	end
		
	gui.set_position(item.root, pos)
end

local function update_list_tabs(list)
	
	for index, item in ipairs(list.items) do
		update_tab(list, item, index - 1)
	end
end

function M.model_tabs(list_id, data, action_id, action, config, fn)

	local data_list = {}
	local first_tab_id = list_id .. "/tab1"

	if M.list_model_tabs[M.current_group] == nil then
		M.list_model_tabs[M.current_group] = {}
	end

	if M.list_model_tabs[M.current_group][list_id] == nil then
		M.list_model_tabs[M.current_group][list_id] = {}
		M.list_model_tabs[M.current_group][list_id].selected_tab = first_tab_id
		M.list_model_tabs[M.current_group][list_id].data = data
	end
	
	for _, tab in ipairs(data) do

		if M.fields[M.current_group][tab.id] == nil then

			local tab_node_id = list_id .. "/" .. tab.id
			
			M.fields[M.current_group][tab_node_id] = {}
			M.fields[M.current_group][tab_node_id].list_id = list_id
			M.fields[M.current_group][tab_node_id].type = "tab"
			M.fields[M.current_group][tab_node_id].label = tab.label
			M.fields[M.current_group][tab_node_id].content_id = tab.content_id

			table.insert(M.fields_by_index[M.current_group], tab_node_id)
		end
		
		table.insert(data_list, tab.id)
	end

	return gooey.horizontal_dynamic_list(list_id, list_id .. "/tabs", first_tab_id, data_list, action_id, action, config, fn, update_list_tabs)
end

function M.init()
	M.field_focused_index = nil
	M.field_focused_key = nil
end

return M