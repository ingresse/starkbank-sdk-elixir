defmodule StarkBankTest do
  use ExUnit.Case
  doctest StarkBank

  @env :sandbox
  @username "user"
  @email "user@email.com"
  @password "password"

  test "charge" do
    {:ok, credentials} = Auth.login(@env, @username, @email, @password)

    customers = [
      %CustomerData{
        name: "Arya Stark",
        email: "arya.stark@westeros.com",
        tax_id: "416.631.524-20",
        phone: "(11) 98300-0000",
        tags: ["little girl", "no one", "valar morghulis", "Stark"],
        address: %AddressData{
          street_line_1: "Av. Faria Lima, 1844",
          street_line_2: "CJ 13",
          district: "Itaim Bibi",
          city: "Sao Paulo",
          state_code: "SP",
          zip_code: "01500-000"
        }
      },
      %CustomerData{
        name: "Jon Snow",
        email: "jon.snow@westeros.com",
        tax_id: "012.345.678-90",
        phone: "(11) 98300-0001",
        tags: ["night`s watch", "lord commander", "knows nothing", "Stark"],
        address: %AddressData{
          street_line_1: "Av. Faria Lima, 1844",
          street_line_2: "CJ 13",
          district: "Itaim Bibi",
          city: "Sao Paulo",
          state_code: "SP",
          zip_code: "01500-000"
        }
      }
    ]

    {:ok, customers} = Charge.Customer.register(credentials, customers)

    {:ok, _all_customers} = Charge.Customer.get(credentials, nil, ["Stark"], nil, 100)

    {:ok, _customer} = Charge.Customer.get_by_id(credentials, hd(customers))
    {:ok, customer} = Charge.Customer.get_by_id(credentials, hd(customers).id)

    altered_customer = %{customer | name: "No One"}

    {:ok, altered_customer} = Charge.Customer.overwrite(credentials, altered_customer)

    {:ok, customers} = Charge.Customer.get(credentials, nil, ["Stark"], nil, 100)

    charges = [
      %ChargeData{
        amount: 10000,
        customer_id: altered_customer.id
      },
      %ChargeData{
        amount: 100_000,
        customer_id: "self",
        due_date: Date.utc_today(),
        fine: 10,
        interest: 15,
        overdue_limit: 3,
        tags: ["cash-in"],
        descriptions: [
          %ChargeDescriptionData{
            text: "part-1",
            amount: 30000
          },
          %ChargeDescriptionData{
            text: "part-2",
            amount: 70000
          }
        ]
      }
    ]

    {:ok, _charges} = Charge.create(credentials, charges)

    {:ok, _response} = Charge.Customer.delete(credentials, customers)
  end
end
