defmodule ListTasks do
  @moduledoc """
  Documentation for `ListTasks`.
  """

  @doc """

  """
  alias Feedback.Command
  alias Feedback.Executor
  alias Feedback.PingFeedback

  def main do
    commands = [
      Command.new("172.24.3.31 Ping", "ping", ["-c", "4", "172.24.3.31"], PingFeedback),
      Command.new("172.24.3.32 Ping", "ping", ["-c", "4", "172.24.3.32"], PingFeedback),
    ]

    Executor.execute(commands)
  end
end
