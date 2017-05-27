defmodule Formex.Validator do
  alias Formex.Form

  @spec validate(Form.t) :: Form.t
  def validate(form) do
    validator = Application.get_env(:formex, :validator)

    form = validator.validate(form)

    Map.put(form, :valid?, valid?(form))
  end

  # obsłuyć kolekcje
  
  
  @spec valid?(Form.t) :: boolean
  defp valid?(form) do 
    subforms_valid? = Form.get_nested(form)
    |> Enum.reduce_while(true, fn item, acc ->
      if item.form.valid? do 
        {:cont, true}
      else
        {:halt, false}
      end
    end)

    if !subforms_valid? do 
      false
    else
      Enum.reduce_while(form.errors, true, fn {k, v}, acc ->
        if Enum.count(v) > 0 do 
          {:halt, false}
        else
          {:cont, true}
        end
      end)
    end
  end

  @callback validate(form :: Formex.Form.t) :: List.t
end