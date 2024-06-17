-- Item Sorter v1.0.0
-- SmoothSpatula

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.hfuncs then Helper = v end end end)
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.tomlfuncs then Toml = v end end 
    params = {
        item_sorter_enabled = true
    }

    params = Toml.config_update(_ENV["!guid"], params)
end)

-- ========== ImGui ==========

local sort_item_enabled = true
gui.add_to_menu_bar(function()
    local new_value, clicked = ImGui.Checkbox("Enable Item Sorter", params['item_sorter_enabled'])
    if clicked then
        params['item_sorter_enabled'] = new_value
        Toml.save_cfg(_ENV["!guid"], params)
    end
end)

-- ========== Utils ==========

function is_player(actor)
    local players = Helper.find_active_instance_all(gm.constants.oP)
    for _, player in ipairs(players) do
        if player.id == actor.id then return true end
    end

    return false
end

-- ========== Main ==========

gm.post_script_hook(gm.constants.item_give, function(self, other, result, args)
    if not params['item_sorter_enabled'] then return end

    local actor = args[1].value
    local amount = args[3].value
    local player_inst = nil

    if not is_player(actor) or #actor.inventory_item_order == 1 then return end
    
    local item_id = gm.array_pop(actor.inventory_item_order)
    
    if actor.inventory_item_stack[item_id+1] ~= amount then return end

    local incoming_item = gm.variable_global_get("class_item")[item_id+1]
    
    for i = #actor.inventory_item_order, 1, -1 do
        local inventory_item = gm.variable_global_get("class_item")[actor.inventory_item_order[i]+1]
        
        if incoming_item[7] <= inventory_item[7] then
            gm.array_insert(actor.inventory_item_order, i, item_id)
            return
        end
    end

    gm.array_insert(actor.inventory_item_order, 0, item_id)
end)
