
from datetime import date, timedelta
from decimal import Decimal
from unittest.mock import patch, MagicMock
from app.services.officer import create_event

# Create a fake database cursor
cursor = MagicMock()
cursor.fetchone.return_value = (999,)

# Create a fake database connection
connection = MagicMock()
connection.__enter__.return_value = connection
connection.cursor.return_value.__enter__.return_value = cursor

# Mock officer authorization and database connection
with patch(
    "app.services.officer.officer_membership",
    return_value={"membership_id": 1, "position": "president"}
), patch(
    "app.services.officer.connect",
    return_value=connection
):

    event_id = create_event(
        club_id=1,
        roll_number="S001",
        name="Budget Security Test",
        event_date=date.today() + timedelta(days=7),
        venue="Test Hall",
        capacity=50,
        estimated=5000,
        allotted=99999
    )

# Inspect SQL statements executed
print("SQL statements executed:")

budget_calls = []

for call in cursor.execute.call_args_list:
    sql = call.args[0]
    params = call.args[1] if len(call.args) > 1 else None

    print(sql.strip())
    print("Parameters:", params)

    # Normalize whitespace and capitalization
    normalized_sql = " ".join(sql.upper().split())

    if "INSERT INTO BUDGET" in normalized_sql:
        budget_calls.append(params)

# Verify budget insertion
assert len(budget_calls) == 1, (
    f"Expected 1 budget insertion, found {len(budget_calls)}"
)

print("\nBudget insertion parameters:", budget_calls[0])

# Check that the requested allotment was not accepted
assert Decimal("99999") not in [
    Decimal(str(value))
    for value in budget_calls[0]
    if isinstance(value, (int, float, Decimal))
], "Security failure: requested allotment was passed to SQL"

# Confirm that the allotted amount is zero
assert Decimal(str(budget_calls[0][2])) == Decimal("0"), (
    "Security failure: allotted budget is not zero"
)

print("\nEvent ID (mock):", event_id)
print("Requested allotment: 99999")
print("Actual allotment passed to SQL:", budget_calls[0][2])
print("PASS: Officer cannot allocate a budget")
