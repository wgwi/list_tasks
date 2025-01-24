defmodule Feedback.Command do
  @doc """
     label: A descriptive name for the command (e.g., "check for node alive").
     command: The system command to run (e.g., ping).
     args: Arguments for the command.
     feedback_fn: The function responsible for handling feedback.
  """
  defstruct label: nil, command: nil, args: [], feedback_fn: nil

  def new(label, command, args, feedback_fn) do
    %__MODULE__{
      label: label,
      command: command,
      args: args,
      feedback_fn: feedback_fn
    }
  end
end
