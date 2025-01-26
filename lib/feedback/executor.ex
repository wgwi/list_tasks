defmodule Feedback.Executor do
  alias Feedback.Command
  alias Feedback.Result

  def execute(commands) do
    tasks = Enum.map(commands, fn %Command{} = cmd ->
      IO.inspect(cmd, label: "Executing Command")
      Task.async(fn -> execute_command(cmd) end)
    end)

    Enum.each(tasks, fn task ->
      result = Task.await(task, 60_000)

      IO.puts("\n--- Command Result: #{result.label} ---")
      handle_result(result)
    end)
  end

  defp execute_command(%Command{label: label, command: command, args: args, feedback_mod: feedback_mod}) do
    try do
      case Porcelain.exec(command, args) do
        %Porcelain.Result{out: out, err: err, status: status} ->
          # Handle non-zero exit statuses as errors
          if status == 0 do
            %Result{status: :ok, label: label, output: out, error: nil, reason: nil, feedback_mod: feedback_mod}
          else
            %Result{status: :failure, label: label, output: out, error: err, reason: "other status", feedback_mod: feedback_mod}
          end

      {:error, reason} ->
        %Feedback.Result{
          status: :error,
          label: label,
          error: to_string(reason),
          reason: "Command execution failed",
          feedback_mod: feedback_mod
        }

      other ->
          %Feedback.Result{
          status: :error,
          label: label,
          error: other,
          reason: "Unexpected Porcelain behavior",
          feedback_mod: feedback_mod
        }
      end
    rescue
        exception ->
            %Feedback.Result{
                status: :error,
                label: label,
                error: Exception.message(exception),
                reason: "Command not found or execution error",
                feedback_mod: feedback_mod
             }
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

