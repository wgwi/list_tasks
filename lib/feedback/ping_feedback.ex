defmodule Feedback.PingFeedback do
  def handle(%{output: output}) do
    IO.puts("Ping Feedback: Success")
    IO.puts("Output: #{String.slice(output, 0..50)}...")
  end

  def handle_error(%{reason: reason, error: error}) do
    IO.puts("Ping Feedback: Error")
    IO.puts("Reason: #{reason}")
    IO.puts("Details: #{error}")
  end
end

