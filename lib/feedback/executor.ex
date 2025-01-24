defmodule Feedback.Executor do
  alias Feedback.Command
  alias Feedback.Result

  def execute(commands) do
    tasks = Enum.map(commands, fn %Command{} = cmd ->
      Task.async(fn -> execute_command(cmd) end)
    end)

    Enum.each(tasks, fn task ->
      result = Task.await(task)

      IO.puts("\n--- Command Result: #{result.label} ---")
      handle_result(result)
    end)
  end

  defp execute_command(%Command{label: label, command: command, args: args, feedback_fn: feedback_fn}) do
    try do
      # Execute the command
      case Porcelain.exec(command, args) do
        %Porcelain.Result{out: out, err: err, status: status} ->
          # Handle non-zero exit statuses as errors
          if status == 0 do
            %Result{status: :ok, label: label, output: out, error: nil, reason: nil}
          else
            %Result{status: :failure, label: label, output: out, error: err, reason: "Non-zero exit status"}
          end

        # Catch-all for unexpected Porcelain behaviors
        other ->
          %Result{status: :error, label: label, error: other, reason: "Unexpected behavior"}
      end
    rescue
      exception ->
        # Handle runtime exceptions (e.g., command not found)
        %Result{status: :error, label: label, error: Exception.message(exception), reason: "Execution error"}
    end
  end

  defp handle_result(%Result{status: :ok, output: output} = result) do
    result.feedback_fn.handle(result)
  end

  defp handle_result(%Result{status: :failure, reason: reason, error: error} = result) do
    IO.puts("Failure: #{reason}")
    IO.puts("Error Output: #{error}")
    result.feedback_fn.handle_error(result)
  end

  defp handle_result(%Result{status: :error, reason: reason, error: error} = result) do
    IO.puts("Error: #{reason}")
    IO.puts("Exception: #{error}")
    result.feedback_fn.handle_error(result)
  end
end

