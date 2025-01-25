defmodule Feedback.Executor do
  alias Feedback.Command
  alias Feedback.Result

  def execute(commands) do
    tasks = Enum.map(commands, fn %Command{} = cmd ->
      IO.inspect(cmd, label: "Executing Command")
      Task.async(fn -> execute_command(cmd) end)
    end)

    Enum.each(tasks, fn task ->
      result = Task.await(task)

      IO.puts("\n--- Command Result: #{result.label} ---")
      handle_result(result)
    end)
  end

  defp execute_command(%Command{label: label, command: command, args: args, feedback_mod: feedback_mod}) do
    try do
      # Execute the command
      case Porcelain.exec(command, args) do
        %Porcelain.Result{out: out, err: err, status: status} ->
          # Handle non-zero exit statuses as errors
          if status == 0 do
            %Result{status: :ok, label: label, output: out, error: nil, reason: nil, feedback_mod: feedback_mod}
          else
            %Result{status: :failure, label: label, output: out, error: err, reason: "other status", feedback_mod: feedback_mod}
          end

        # Catch-all for unexpected Porcelain behaviors
        other ->
          %Result{status: :error, 
                  label: label, 
                  error: other, 
                  reason: "Unexpected behavior",
                  feedback_mod: feedback_mod}
      end
    rescue
      exception ->
        # Handle runtime exceptions (e.g., command not found)
        %Result{status: :error, 
                label: label, 
                error: Exception.message(exception), 
                reason: "Execution error",
                feedback_mod: feedback_mod}
    end
  end

  defp handle_result(%Result{status: :ok, 
                             output: output, 
                             feedback_mod: feedback_mod} = result) do
    feedback_mod.handle(result)
  end

  defp handle_result(%Result{status: :failure, 
                             reason: reason, 
                             error: error, 
                             feedback_mod: feedback_mod} = result) do
    IO.puts("Failure: #{reason}")
    IO.puts("Error Output: #{error}")
    feedback_mod.handle_error(result)
  end

  defp handle_result(%Result{status: :error, 
                             reason: reason, 
                             error: error,
                             feedback_mod: feedback_mod} = result) do
    IO.puts("Error: #{reason}")
    IO.puts("Exception: #{error}")
    feedback_mod.handle_error(result)
  end
end

