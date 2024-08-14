# Import the necessary Selenium PowerShell module
Import-Module Selenium

# Set up the Selenium WebDriver and specify the browser
$driver = Start-SeChrome

# Define the base URL for the web application you are testing
$baseUrl = "http://localhost:8080"

try {
    # Step 1: Navigate to the home page
    Write-Host "Navigating to home page..."
    $driver.Navigate().GoToUrl("$baseUrl/home")
    Start-Sleep -Seconds 2

    # Verify the title of the page
    $title = $driver.Title
    if ($title -eq "Home - My Web App") {
        Write-Host "Home page loaded successfully."
    } else {
        Write-Host "Failed to load home page. Title: $title"
    }

    # Step 2: Navigate to the login page
    Write-Host "Navigating to login page..."
    $driver.FindElementByLinkText("Login").Click()
    Start-Sleep -Seconds 2

    # Verify the title of the login page
    $title = $driver.Title
    if ($title -eq "Login - My Web App") {
        Write-Host "Login page loaded successfully."
    } else {
        Write-Host "Failed to load login page. Title: $title"
    }

    # Step 3: Perform login
    Write-Host "Performing login..."
    $driver.FindElementById("username").SendKeys("testuser")
    $driver.FindElementById("password").SendKeys("password123")
    $driver.FindElementById("loginButton").Click()
    Start-Sleep -Seconds 2

    # Verify login success by checking the presence of a logout link
    if ($driver.FindElementByLinkText("Logout")) {
        Write-Host "Login successful."
    } else {
        Write-Host "Login failed."
    }

    # Step 4: Navigate to the user profile page
    Write-Host "Navigating to user profile page..."
    $driver.FindElementByLinkText("Profile").Click()
    Start-Sleep -Seconds 2

    # Verify the title of the profile page
    $title = $driver.Title
    if ($title -eq "Profile - My Web App") {
        Write-Host "Profile page loaded successfully."
    } else {
        Write-Host "Failed to load profile page. Title: $title"
    }

    # Step 5: Update user profile information
    Write-Host "Updating user profile information..."
    $driver.FindElementById("firstName").Clear()
    $driver.FindElementById("firstName").SendKeys("Test")
    $driver.FindElementById("lastName").Clear()
    $driver.FindElementById("lastName").SendKeys("User")
    $driver.FindElementById("saveProfileButton").Click()
    Start-Sleep -Seconds 2

    # Verify that the profile was updated
    $successMessage = $driver.FindElementById("successMessage").Text
    if ($successMessage -eq "Profile updated successfully.") {
        Write-Host "Profile updated successfully."
    } else {
        Write-Host "Failed to update profile. Message: $successMessage"
    }

    # Step 6: Log out
    Write-Host "Logging out..."
    $driver.FindElementByLinkText("Logout").Click()
    Start-Sleep -Seconds 2

    # Verify that the user is redirected to the login page after logout
    $title = $driver.Title
    if ($title -eq "Login - My Web App") {
        Write-Host "Logout successful. Redirected to login page."
    } else {
        Write-Host "Logout failed. Title: $title"
    }

} catch {
    Write-Host "An error occurred during the test: $_"
} finally {
    # Close the browser and clean up
    Stop-SeDriver -Driver $driver
    Write-Host "Test completed."
}
