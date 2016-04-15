require "lita"

Lita.load_locales Dir[File.expand_path(
  File.join("..", "..", "locales", "*.yml"), __FILE__
)]

# Helpers
require "lita/helpers/team-helpers"

require "lita/handlers/team_balance"
require "lita/handlers/set_score"

Lita::Handlers::TeamBalance.template_root File.expand_path(
  File.join("..", "..", "templates"),
 __FILE__
)
