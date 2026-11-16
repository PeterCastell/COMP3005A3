# COMP 3005 Assignment 3, Question 1

A PostgreSQL client for a `students` table, written in
[Brainfuck++](https://github.com/PeterCastell/BrainfuckPlusPlus).

It uses no database driver. The program opens a TCP socket, logs in with
SCRAM-SHA-256 and exchanges PostgreSQL protocol messages itself, calling only
libraries that ship with Windows.

## Video

VIDEO LINK GOES HERE

## Requirements

- Windows 10 or later, 64-bit
- PostgreSQL running on `localhost`, port `5432` (tested with version 17)
- The Brainfuck++ compiler, `bfpp` version 1.3.0. See its
  [getting started page](https://github.com/PeterCastell/BrainfuckPlusPlus/wiki/Getting-Started).

## Database setup

1. Create the database, from pgAdmin or `psql`:

   ```sql
   CREATE DATABASE comp3005_a3;
   ```

2. Create the table and load the initial data by running
   [scripts/setup.sql](scripts/setup.sql) on that database. Either open it in
   the pgAdmin Query Tool, or run:

   ```bat
   scripts\reset.bat
   ```

`reset.bat` runs `setup.sql` with `psql` as the user `postgres` and asks for
the password. It drops and recreates the table, so it also puts the data back
after the program has changed it.

## Compile and run

From this folder:

```bat
bfpp run
```
This compiles the project and starts it.


Run `scripts\reset.bat` before running the program again. The second run
would otherwise stop at the insert, because the email it adds already exists.

## Application functions

The four functions are macros in [src/main.bfpp](src/main.bfpp). Each one
fills in a SQL template, sends it and prints the result.

| Function | What it does |
|---|---|
| `getAllStudents` | Prints every row of `students`, ordered by `student_id`. |
| `addStudent (first_name) (last_name) (email) (enrollment_date)` | Inserts a new student. |
| `updateStudentEmail (student_id) (new_email)` | Changes the email of one student. |
| `deleteStudent (student_id)` | Deletes one student. |

An argument is code that writes a string, so a call looks like this:

```
$addStudent (+"Ada") (+"Lovelace") (+"ada.lovelace@example.com") (+"2023-09-03")
$updateStudentEmail (+"1") (+"john@example.com")
$deleteStudent (+"3")
```

The calls the program makes are at the end of `src/main.bfpp`. It lists the
students, adds one, changes the email of student 1 and deletes student 3,
listing the table again after each change.

## Connection settings

The server address, port, user and database are the arguments of `db_connect`
in `src/main.bfpp`:

```bfpp
$db_connect
    (+127 >3 +1 <3) # ip
    (+21 > +56 <) # port
    (+"postgres")
    (+"comp3005_a3")
    (+"Password: " $print_nt $clear_nt $read_line)
```

The first argument is the four bytes of the IPv4 address and the second is the
two bytes of the port, high byte first (21 * 256 + 56 = 5432).

The server must use `scram-sha-256` or `trust` authentication for local
connections. `scram-sha-256` has been the default since PostgreSQL 14.

## Project structure

| Path | Contents |
|---|---|
| `src/main.bfpp` | Entrypoint and four required functions |
| `src/db.bfpp` | PostgreSQL protocol and result formatting |
| `src/net.bfpp` | TCP sockets |
| `src/functions.bfpp` | Library function loader |
| `src/utils.bfpp` | General macros |
| `scripts/setup.sql` | Creates/resets the `students` table and its initial rows |
| `scripts/reset.bat` | Runs `setup.sql` to reset the table |
| `notes.md` | Where everything is stored on the memory tape |
| `project.toml` | BFPP project settings |

The program calls functions from four libraries that are part of Windows:
* `ws2_32` (sockets)
* `bcrypt` (hashing)
* `crypt32` (base64)
* `msvcrt`
(string formatting)

## Limitations

- Values are templated into the SQL as they are. A value that contains a single
  quote breaks the query.
- An error from the server, such as a duplicate email, is printed and ends
  the program.
- The password is visible while it is typed.
