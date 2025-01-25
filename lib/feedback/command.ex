defmodule Feedback.Command do
  defstruct label: nil, command: nil, args: [], feedback_mod: nil

  @doc """
     Creates a new `Feedback.Command` struct.
     label: A descriptive name for the command (e.g., "check for node alive").
     command: The system command to run (e.g., ping).
     args: Arguments for the command.
     feedback_mod: The module responsible for handling feedback.
  """
  def new(label, command, args, feedback_mod) do
    cond do
      is_binary(label) and is_binary(command) and is_list(args) and is_atom(feedback_mod) ->
        %__MODULE__{
          label: label,
          command: command,
          args: args,
          feedback_mod: feedback_mod
        }

      true ->
        raise ArgumentError, "Invalid arguments for Feedback.Command.new/4"
    end
  end
end

