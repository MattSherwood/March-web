# Project: March to 500 Membership Rally

This document provides the technical specifications and implementation steps for the "March to 500" campaign dashboard and its associated creative assets.

---

## 1. Core Implementation Files

### A. Data Schema (`data.json`)
This is your single source of truth. Edit the `current` value manually to update all widgets.

```json
{
  "current": 342,
  "goal": 500,
  "lastUpdated": "Feb 25, 2026"
}
```

### B. Dashboard & Widget (`index.html`)
This file handles both the full landing page and the compact iFrame widget. The colors are mapped to your Beatrix Potter mood board (Sage Green and Dusty Rose).

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>March to 500 | Join the Movement</title>
    <link rel="icon" href="[https://fav.farm/](https://fav.farm/)🚀" />
    
    <meta property="og:type" content="website">
    <meta property="og:url" content="[https://march.pithyprint.com/](https://march.pithyprint.com/)">
    <meta property="og:title" content="March to 500 Membership Rally">
    <meta property="og:description" content="Help us reach our goal of 500 members! See our live progress and join the community.">
    <meta property="og:image" content="[https://march.pithyprint.com/images/social-preview.png](https://march.pithyprint.com/images/social-preview.png)">

    <style>
        :root {
            /* Colors from Beatrix Potter Mood Board */
            --sage-green: #7d9689; 
            --dusty-rose: #d6857a;
            --moss-green: #8b964d;
            --bg-cream: #fcfaf2;
            --text-dark: #4a4a4a;
        }
        body { 
            font-family: 'Georgia', serif; 
            margin: 0; 
            padding: 40px 20px; 
            background: var(--bg-cream); 
            color: var(--text-dark); 
            display: flex; 
            flex-direction: column; 
            align-items: center; 
        }
        
        /* Compact Widget Mode */
        body.widget-mode { padding: 5px; background: transparent; overflow: hidden; }
        body.widget-mode .header { display: none; }

        .container { width: 100%; max-width: 500px; text-align: center; }
        
        .header h2 { color: var(--sage-green); margin-bottom: 5px; }
        .header p { font-style: italic; margin-top: 0; color: var(--dusty-rose); }

        .progress-container {
            background: #e9e4d9;
            border-radius: 15px;
            height: 32px;
            width: 100%;
            position: relative;
            overflow: hidden;
            border: 2px solid var(--sage-green);
        }

        .progress-bar {
            background: linear-gradient(90deg, var(--sage-green), var(--moss-green));
            height: 100%;
            width: 0%; 
            transition: width 2s cubic-bezier(0.1, 0.5, 0.1, 1);
        }

        .stats { margin-top: 15px; font-weight: bold; font-size: 1.4rem; color: var(--text-dark); }
        .update-tag { font-size: 0.8rem; color: #888; margin-top: 8px; text-transform: uppercase; letter-spacing: 1px; }
    </style>
</head>
<body>

    <div class="container">
        <div class="header">
            <h2>March to 500</h2>
            <p>A Beatrix Potter Easter Rally</p>
        </div>

        <div class="progress-container">
            <div id="bar" class="progress-bar"></div>
        </div>

        <div class="stats">
            <span id="current">0</span> / <span id="goal">500</span> Members
        </div>
        <div id="date" class="update-tag">Updated: --</div>
    </div>

    <script>
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get('view') === 'widget') {
            document.body.classList.add('widget-mode');
        }

        async function updateTracker() {
            try {
                const response = await fetch('data.json?v=' + Date.now());
                const data = await response.json();
                const percent = Math.min((data.current / data.goal) * 100, 100);
                
                setTimeout(() => {
                    document.getElementById('bar').style.width = percent + '%';
                    document.getElementById('current').innerText = data.current;
                    document.getElementById('goal').innerText = data.goal;
                    document.getElementById('date').innerText = 'Updated: ' + data.lastUpdated;
                }, 500);
            } catch (e) {
                console.error("Error loading stats", e);
            }
        }

        updateTracker();
    </script>
</body>
</html>
```

---

## 2. Step-by-Step Implementation

### Step 1: GitHub Directory Structure
Ensure your repository is organized as follows:
* `/index.html`
* `/data.json`
* `/images/social-preview.png`
* `/images/mobile-wallpaper.png`
* `/images/desktop-wallpaper.png`

### Step 2: DNS & Hosting
1. Set up **GitHub Pages** to serve from the root of your repo.
2. In **GoDaddy**, ensure `march.pithyprint.com` is a CNAME pointing to your GitHub URL.

### Step 3: Integration
1. **FEA Create iFrame:**
   ```html
   <iframe src="[https://march.pithyprint.com?view=widget](https://march.pithyprint.com?view=widget)" 
           style="width:100%; height:140px; border:none; background:transparent;" 
           scrolling="no">
   </iframe>
   ```
2. **Facebook:** Use the URL `https://march.pithyprint.com`. If the image doesn't show, use the [Facebook Sharing Debugger](https://developers.facebook.com/tools/debug/) to "Scrape Again."

### Step 4: Updating the Count
Simply edit the `current` value in `data.json` on GitHub. The CSS transition will handle the "animating" progress bar automatically for your users.