defmodule ListTasks do
  @moduledoc """
  Documentation for `ListTasks`.
  """

  alias Feedback.Command
  alias Feedback.Executor
  alias Feedback.PingFeedback

  def main do
    commands = [
      Command.new("172.24.3.31 Ping", "ping", ["-c", "4", "172.24.3.31"], PingFeedback),
      Command.new("172.24.3.32 Ping", "ping", ["-c", "4", "172.24.3.32"], PingFeedback),
      Command.new("no existing node Ping", "ping", ["-c", "4", "172.24.3.50"], PingFeedback),
      Command.new("no_command", "guess", [], PingFeedback)
    ]

    #IO.inspect(commands, label: "Generated Commands") # Add debug info here

    Executor.execute(commands)
  end
end
