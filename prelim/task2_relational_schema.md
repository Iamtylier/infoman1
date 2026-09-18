Task 2 - Relational Schema (ToolShare)

Notation: primary key columns are written in ALL CAPS. Foreign keys are marked with "FK" right after the column name.

Member(MEMBER_ID, name, phone, membership_start_date)

StorageLocation(LOCATION_CODE, description)

Tool(TOOL_ID, name, category, purchase_date, location_code FK)

Certification(CERT_ID, name)

Borrowing(BORROWING_ID, member_id FK, tool_id FK, borrow_date, return_date)

ToolCertification(TOOL_ID FK, CERT_ID FK)

MemberCertification(MEMBER_ID FK, CERT_ID FK, completion_date)

Notes on each table

Member

Core entity from the spec. member_id is its own natural identifier.
No weak entity, no resolution needed.

StorageLocation

Core entity. location_code is its own natural identifier.

Tool

Core entity. Gains location_code as an FK to StorageLocation, to implement the mandatory 1:M "stores" relationship.
location_code is NOT NULL because every tool must be assigned to a location (total participation on the Tool side).

Certification

Core entity. cert_id is its own natural identifier.

Borrowing

Resolves the M:N relationship "Member borrows Tool".
That relationship carried its own attributes (borrow_date, return_date), so it becomes its own table instead of a plain junction table.
Uses a surrogate key (borrowing_id) instead of a composite (member_id, tool_id) key, because a member can legitimately borrow the same tool more than once over time. A composite key on just those two columns could not represent two separate borrowing events for the same member/tool pair.

ToolCertification

Resolves the M:N relationship "Tool requires Certification".
Pure junction table - the relationship itself carries no attributes.
The composite primary key (tool_id, cert_id) is both the identifier and the full set of foreign keys.

MemberCertification

Resolves the M:N relationship "Member completes Certification".
Carries the relationship's own attribute, completion_date.
Composite primary key (member_id, cert_id) - a member completes a given certification once.

Overall

No weak entities were present in the spec, since every entity has its own natural identifier. No multivalued, composite, or derived attributes were identified in the written description either, so nothing needed decomposition beyond resolving the three M:N relationships above into Borrowing, ToolCertification, and MemberCertification.