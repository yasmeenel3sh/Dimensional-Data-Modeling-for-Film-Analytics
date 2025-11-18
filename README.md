# Dimensional Data Modeling 

This assignment involves working with the `actor_films` dataset. The task is to construct a series of SQL queries and table definitions that will allow us to model the actor_films dataset in a way that facilitates efficient analysis. This involves creating new tables, defining data types, and writing queries to populate these tables with data from the actor_films dataset

## Dataset Overview
The `actor_films` dataset contains the following fields:

- `actor`: The name of the actor.
- `actorid`: A unique identifier for each actor.
- `film`: The name of the film.
- `year`: The year the film was released.
- `votes`: The number of votes the film received.
- `rating`: The rating of the film.
- `filmid`: A unique identifier for each film.

The primary key for this dataset is (`actor_id`, `film_id`).

## Tasks Done

1. **DDL for `actors` table:** Create a DDL for an `actors` table with the following fields:
    - `films`: An array of `struct` with the following fields:
		- film: The name of the film.
		- votes: The number of votes the film received.
		- rating: The rating of the film.
		- filmid: A unique identifier for each film.

    - `quality_class`: This field represents an actor's performance quality, determined by the average rating of movies of their most recent year. It's categorized as follows:
		- `star`: Average rating > 8.
		- `good`: Average rating > 7 and ≤ 8.
		- `average`: Average rating > 6 and ≤ 7.
		- `bad`: Average rating ≤ 6.
    - `is_active`: A BOOLEAN field that indicates whether an actor is currently active in the film industry (i.e., making films this year).
    
2. **Cumulative table generation query:** Write a query that populates the `actors` table one year at a time.
    
3. **DDL for `actors_history_scd` table:** Create a DDL for an `actors_history_scd` table with the following features:
    - Implements type 2 dimension modeling (i.e., includes `start_date` and `end_date` fields).
    - Tracks `quality_class` and `is_active` status for each actor in the `actors` table.
      
4. **Backfill query for `actors_history_scd`:** Write a "backfill" query that can populate the entire `actors_history_scd` table in a single query.
    
5. **Incremental query for `actors_history_scd`:** Write an "incremental" query that combines the previous year's SCD data with new incoming data from the `actors` table.




# 📊 Get Set for Data Modeling 


1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop)  
2. Copy the env template:

```bash
cp example.env .env
```

> The `.env` file stores credentials used by PostgreSQL and PGAdmin

3. Start PostgreSQL & PGAdmin in containers:

```bash
# Mac users:
make up

# Windows (or general):
docker compose up -d
```

4. Check containers are running:

```bash
docker ps -a
```

5. When you're done with work:

```bash
docker compose stop
```


### Connect to PostgreSQL

Choose any GUI tool you like. Here’s how:

#### 🌐 If using PGAdmin (via Docker browser)

1. Go to [http://localhost:5050](http://localhost:5050)  
2. Log in using the credentials from your `.env` file  
3. Create a new server:  
	1. `Dashboard` ➜ `Quick Links` ➜ `Add New Server`
	2. Under the `General` tab: give it a friendly `Name`, e.g. `Data-Engineer-Handbook-DB`
	3. `Connection` tab: Copy in credentials from `.env`, where the defaults are:
	   - **Name**: Name of your choice  
	   - **Host**: `my-postgres-container`  
	   - **Port**: `5432`  
	   - **Database**: `postgres`  
	   - **Username**: `postgres`  
	   - **Password**: `postgres`  
	   - ✅ Save Password  
4. Click **Save** — and you’re connected!
5. Expand `Servers`  › *`your-server`* › `Databases` › `postgres`
	- The database must be highlighted to be able to open the `Query Tool`
	- Further expanding `postgres` › `Schemas` › `public` › `Tables` should show the expected content

---

#### 💻 If using a desktop client (like DataGrip, DBeaver, or VS Code)

Use the following values to set up a new PostgreSQL connection:
   - **Host**: `localhost`  
   - **Port**: `5432`  
   - **Database**: `postgres`  
   - **Username**: `postgres`  
   - **Password**: `postgres`  
   - ✅ Save Password  

✅ Test & Save your connection and you’re good to go.

---

### 🔁 Want a fresh start?

Stop and remove all running containers:

```bash
docker compose down
docker compose up -d
```

Or use:

```bash
make restart
```

---

## 🔧 Helpful Docker Make Commands

| Command           | What it does                    |
|------------------|----------------------------------|
| `make up`        | Start Postgres and PGAdmin       |
| `make stop`      | Stop both containers             |
| `make restart`   | Restart the Postgres container   |
| `make logs`      | View logs from containers        |
| `make inspect`   | Inspect container configuration  |
| `make ip`        | Get container IP address         |

---

🎉 That’s it!
