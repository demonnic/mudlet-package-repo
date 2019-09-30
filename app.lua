local lapis = require("lapis")
local respond_to = lapis.application.respond_to
local app = lapis.Application()
local config = require("lapis.config").get()
local db = require("lapis.db")
local Model = require("lapis.db.model").Model
local Users = require("models.users")
local Packages = require("models.packages")
local login = require("controllers.login")
local register = require("controllers.register")



app:enable("etlua")
app.layout = require('views.layout')

local config_before = require("controllers.config")

app:before_filter(config_before)
-- base route
app:get("index", "/", function(self)
  local name = self.session.name or "unknown"
  return self.i18n("greeting", {name})
end)

app:get("/packages", function()
  local packages = db.select("* from packages")
  return { json = packages}
end)

app:match("login", "/login", respond_to(login))

app:get("/getuser1packages", function(self)
  local user = Users:find(1)
  local packages = user:get_packages()
  return {json = packages}
end)

-- new user route
app:match("register", "/register", respond_to(register))

app:get("newpackage", "/newpackage", function(self)
  local package = Packages:create({
    name = self.params.name,
    version = self.params.version,
    description = self.params.description or "",
    user_id = self.params.user_id or 1,
    extension = self.params.extension or "xml",
  })
  if package then return self.i18n("upload_success", {self.params.name}) end
end)

return app