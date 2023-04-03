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

	err := godotenv.Load()
	if err != nil {
		log.Fatal(".env file could not be loaded")
	}

	username := os.Getenv("USERNAME")
	pass := os.Getenv("PASSWORD")

	dbURL := username + ":" + pass + "@tcp(localhost:3306)/workshop"

	// Open a database connection
	db, err := sql.Open("mysql", dbURL)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	// Prepare the stored procedure call
	stmt, err := db.Prepare("CALL book1(?, ?, ?)")
	if err != nil {
		panic(err)
	}

	// Define the workshop IDs, user IDs, and booking dates to use
	workshopIDs := []int{1, 2}
	userIDs := []int{1, 2, 3, 4, 5, 6, 7}
	bookingDates := []string{"2023-03-29"}

	// Define a wait group to synchronize the goroutines
	var wg sync.WaitGroup

	// Launch multiple goroutines to call the stored procedure concurrently
	for i := 0; i < 10; i++ {
		wg.Add(1)

		go func() {
			defer wg.Done()

			// Pick a random workshop, user, and booking date to use
			r1 := rand.Intn(len(workshopIDs))
			r2 := rand.Intn(len(userIDs))
			wid := workshopIDs[r1]
			uid := userIDs[r2]
			bdate := bookingDates[0]

			// Call the stored procedure
			_, err := stmt.Exec(wid, uid, bdate)
			if err != nil {
				fmt.Println(err)
			}

			fmt.Printf("Booking completed for workshop %d, user %d, and date %s\n", wid, uid, bdate)
		}()
	}

	// Wait for all goroutines to complete
	wg.Wait()

	fmt.Println("All bookings completed")
}
