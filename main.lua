-- Item Sorter v1.0.5
-- SmoothSpatula

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function() for _, m in pairs(mods) do if type(m) == "table" and m.RoRR_Modding_Toolkit then for _, c in ipairs(m.Classes) do if m[c] then _G[c] = m[c] end end end end end)
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

-- ========== Main ==========

gm.post_script_hook(gm.constants.item_give_internal, function(self, other, result, args)
    if not params['item_sorter_enabled'] then return end

    local actor = args[1].value
    local item_id = args[2].value
    local amount = args[3].value
    local item_index = #actor.inventory_item_order-1
    local incoming_item = Item.wrap(item_id)

    print(incoming_item.identifier)
    print(incoming_item.tier)

    if actor.object_name ~= "oP" or #actor.inventory_item_order == 1 or incoming_item.is_hidden==true then return end

    local incoming_amount = actor.inventory_item_stack[item_id+1]
    if incoming_amount ~= amount then
        item_index = gm.array_get_index(actor.inventory_item_order, item_id)
    end
    gm.array_delete(actor.inventory_item_order, item_index, 1)

    
    for i = #actor.inventory_item_order, 1, -1 do
        local inventory_item = gm.variable_global_get("class_item")[actor.inventory_item_order[i]+1]

        local inventory_amount = actor.inventory_item_stack[actor.inventory_item_order[i]+1]
        
        if incoming_item.tier < inventory_item[7] 
        or (incoming_item.tier == inventory_item[7] and incoming_amount <= inventory_amount) then
            gm.array_insert(actor.inventory_item_order, i, item_id)
            return
        end
    end

    gm.array_insert(actor.inventory_item_order, 0, item_id)
end)
