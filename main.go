package main

import (
	"database/sql"
	"fmt"
	"log"
	"math/rand"
	"os"
	"sync"

	// "time"

	_ "github.com/go-sql-driver/mysql"

	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	err := godotenv.Load()
	if err != nil {
		log.Fatal(".env file could not be loaded")
	}

	username := os.Getenv("USERNAME")
	pass := os.Getenv("PASSWORD")

	// Setting up the connection to the "workshop" database
	dbURL := username + ":" + pass + "@tcp(localhost:3306)/workshop"

	// Open a database connection
	db, err := sql.Open("mysql", dbURL)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	// Prepare the call book1 statement for executing later
	stmt, err := db.Prepare("CALL book1(?, ?, ?)")
	if err != nil {
		panic(err)
	}

	workshopIDs := []int{1, 2}
	userIDs := []int{1, 2, 3, 4, 5, 6, 7}
	bookingDates := []string{"2023-03-29"}

	var wg sync.WaitGroup

	// Launching multiple goroutines
	// Loop runs 10 times
	for i := 0; i < 10; i++ {
		wg.Add(1)

		go func() {
			defer wg.Done()

			// Picking a random workshop, user, and booking date to use
			r1 := rand.Intn(len(workshopIDs))
			r2 := rand.Intn(len(userIDs))
			wid := workshopIDs[r1]
			uid := userIDs[r2]
			bdate := bookingDates[0]

			// Calling the stored procedure
			_, err := stmt.Exec(wid, uid, bdate)
			if err != nil {
				fmt.Println(err)
			}

			fmt.Printf("Booking completed for workshop %d, user %d, and date %s\n", wid, uid, bdate)
		}()
	}

	// Waiting for all goroutines to complete
	wg.Wait()

	fmt.Println("All bookings completed")
}
