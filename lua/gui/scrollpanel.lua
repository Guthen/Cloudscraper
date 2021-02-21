ScrollPanel = class( Panel )
ScrollPanel.scroll_y, ScrollPanel.scroll_step = 0, 35
ScrollPanel.max_scroll_y = math.huge

function ScrollPanel:stencil( w, h )
    love.graphics.rectangle( "fill", 0, 0, w, h )
end

function ScrollPanel:updatescroll( y )
    self.scroll_y = y
    for i, v in ipairs( self.children ) do
        v.y = v._y - self.scroll_y
    end
end

function ScrollPanel:wheelmove( x, y )
    if not self.is_hovered then return end
    self:updatescroll( clamp( self.scroll_y - y * self.scroll_step, 0, self.max_scroll_y ) )
end

function ScrollPanel:draw( w, h, force )
    if not ( force == true ) and self.parent then return end --  > draw only if forced when parented

    Camera:pop()

    love.graphics.push()
    love.graphics.translate( self.x, self.y )

    love.graphics.stencil( function() self:stencil( self.w, self.h ) end, "replace", 1 )
    love.graphics.setStencilTest( "greater", 0 )

    self:paint( self.w, self.h )
    for i, v in ipairs( self.children ) do
        v:draw( w, h, true )
    end

    love.graphics.setStencilTest()
    love.graphics.pop()
    
    Camera:push()
end