// import { useState } from 'react'
// import './App.css'

//import Button from "@mui/material/Button";
//import Box from '@mui/material/Box';
//import Home from './pages/home';
import TopNav from '../components/layouts/TopNav';
import { CssBaseline } from '@mui/material';

// import MyTheme from './styles/Themes.js';

function App() {
  // const [count, setCount] = useState(0);

  return (  
    <div>
    <CssBaseline />    
    <TopNav />
    </div>

    /*
    <Box
      sx={{
        display: 'flex-vertical',
        width: '100%',
        alignItems: 'center',
        justifyContent: 'center',
        bgcolor: 'background.default',
        color: 'text.primary',
        borderRadius: 1,
        p: 3,
        border: '1px solid black'
      }}
    >    
{
      <div>
        <a href="https://vitejs.dev" rel="noreferrer" target="_blank">
          <img src={viteLogo} className="logo" alt="Vite logo" />
        </a>
        <a href="https://react.dev" rel="noreferrer" target="_blank">
          <img src={reactLogo} className="logo react" alt="React logo" />
        </a>
      </div>

      <h1>Vite + React (Hello!)</h1>

      <div className="card">
        <Button onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </Button>
        <p>
          Edit <code>src/App.jsx</code> and save to test HMR
        </p>
      </div>

      <p className="read-the-docs">
        Click on the Vite and React logos to learn more
    </p>  }
    </Box>*/
  );
}
export default App
