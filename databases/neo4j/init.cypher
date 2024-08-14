// Create a constraint to ensure unique user IDs
CREATE CONSTRAINT user_id_unique IF NOT EXISTS
FOR (u:User)
REQUIRE u.id IS UNIQUE;

// Create a constraint to ensure unique task IDs
CREATE CONSTRAINT task_id_unique IF NOT EXISTS
FOR (t:Task)
REQUIRE t.id IS UNIQUE;

// Create an index on the User name for faster lookups
CREATE INDEX user_name_index IF NOT EXISTS
FOR (u:User)
ON (u.name);

// Create an index on the Task due date for sorting
CREATE INDEX task_due_date_index IF NOT EXISTS
FOR (t:Task)
ON (t.dueDate);

// Example Data: Create some initial users
CREATE (u1:User {id: 'user1', name: 'Alice', email: 'alice@example.com'});
CREATE (u2:User {id: 'user2', name: 'Bob', email: 'bob@example.com'});

// Example Data: Create some initial tasks
CREATE (t1:Task {id: 'task1', title: 'Finish report', dueDate: '2024-08-15', status: 'Pending'});
CREATE (t2:Task {id: 'task2', title: 'Call John', dueDate: '2024-08-14', status: 'Pending'});

// Create relationships between users and tasks
CREATE (u1)-[:ASSIGNED_TO]->(t1);
CREATE (u2)-[:ASSIGNED_TO]->(t2);

// Example Data: Create a few relationships to indicate task dependencies
CREATE (t1)-[:DEPENDS_ON]->(t2);
