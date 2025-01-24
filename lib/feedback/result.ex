defmodule Feedback.Result do
  @doc """
     :status: Can be :ok, :error, or :failure.
     :label: The label of the command (e.g., "ls").
     :output: Captures command output (stdout and/or stderr).
     :error: Any runtime errors or exceptions.
     :reason: Additional information about the failure (e.g., "command not found").
  """
  defstruct status: :ok, label: nil, output: nil, error: nil, reason: nil
end

