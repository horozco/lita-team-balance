require "lita"

Lita.load_locales Dir[File.expand_path(
  File.join("..", "..", "locales", "*.yml"), __FILE__
)]

# Helpers
require "lita/helpers/team-helpers"
require "lita/helpers/array"

#Handlers
require "lita/handlers/team_balance"
require "lita/handlers/balance"
require "lita/handlers/clear_scores"
require "lita/handlers/get_scores"
require "lita/handlers/set_scores"

require 'terminal-table'

Lita::Handlers::TeamBalance.template_root File.expand_path(
  File.join("..", "..", "templates"),
 __FILE__
)
