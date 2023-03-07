# frozen_string_literal: true

require_relative "setup"

run lambda(env) do
  [
    200,
    { "Content-Type" => "text/plain" },
    ["ok"]
  ]
end
