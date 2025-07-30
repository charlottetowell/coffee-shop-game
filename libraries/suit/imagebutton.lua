-- This file is part of SUIT, copyright (c) 2016 Matthias Richter

local BASE = (...):match('(.-)[^%.]+$')

local function isType(val, typ)
	return type(val) == "userdata" and val.typeOf and val:typeOf(typ)
end

return function(core, normal, ...)
	local opt, x,y = core.getOptionsAndSize(...)
	opt.normal = normal or opt.normal or opt[1]
	opt.hovered = opt.hovered or opt[2] or opt.normal
	opt.active = opt.active or opt[3] or opt.hovered
	opt.id = opt.id or opt.normal
	opt.scale = opt.scale or 1

	local image = assert(opt.normal, "No image for state `normal'")

	core:registerMouseHit(opt.id, x, y, function(u,v)
		-- mouse in image?
		u, v = math.floor(u+.5), math.floor(v+.5)
		local scaledWidth = image:getWidth() * opt.scale
		local scaledHeight = image:getHeight() * opt.scale
		if u < 0 or u >= scaledWidth or v < 0 or v >= scaledHeight then
			return false
		end

		if opt.mask then
			-- alpha test
			-- convert scaled coordinates back to original image coordinates
			local originalU = math.floor(u / opt.scale + 0.5)
			local originalV = math.floor(v / opt.scale + 0.5)
			assert(isType(opt.mask, "ImageData"), "Option `mask` is not a love.image.ImageData")
			assert(originalU < opt.mask:getWidth() and originalV < opt.mask:getHeight(), "Mask may not be smaller than image.")
			local _,_,_,a = opt.mask:getPixel(originalU, originalV)
			return a > 0
		end

		return true
	end)

	if core:isActive(opt.id) then
		image = opt.active
	elseif core:isHovered(opt.id) then
		image = opt.hovered
	end

	assert(isType(image, "Image"), "state image is not a love.graphics.image")

	local r, g, b, a = love.graphics.getColor()
	core:registerDraw(opt.draw or function(image,x,y, r,g,b,a, scale)
		love.graphics.setColor(r or 1, g or 1, b or 1, a or 1)
		love.graphics.draw(image, x, y, 0, scale, scale)
	end, image, x,y, r or 1, g or 1, b or 1, a or 1, opt.scale)

	return {
		id = opt.id,
		hit = core:mouseReleasedOn(opt.id),
		hovered = core:isHovered(opt.id),
		entered = core:isHovered(opt.id) and not core:wasHovered(opt.id),
		left = not core:isHovered(opt.id) and core:wasHovered(opt.id)
	}
end
