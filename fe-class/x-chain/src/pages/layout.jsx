import * as React from 'react';

import { Outlet } from 'react-router-dom'

import { CssBaseline } from '@mui/material'; // Keep before other Mui imports.

import { useTheme, ThemeProvider, createTheme } from '@mui/material/styles';
import IconButton from '@mui/material/IconButton';
import Box from '@mui/material/Box';
import { orange } from '@mui/material/colors';
import Brightness4Icon from '@mui/icons-material/Brightness4';
import Brightness7Icon from '@mui/icons-material/Brightness7';

import TopNav from '../components/layouts/TopNav';

import '@fontsource/roboto/300.css';
import '@fontsource/roboto/400.css';
import '@fontsource/roboto/500.css';
import '@fontsource/roboto/700.css';
import Footer from '../components/layouts/Footer';

export const ColorModeContext = React.createContext({ toggleColorMode: () => {} });

export function ColorToggler() {
  const theme = useTheme();
  const colorMode = React.useContext(ColorModeContext);

  return (
    <div>
    <Box
      sx={{
        display: 'flex',
        width: '100%',
        alignItems: 'center',
        justifyContent: 'center',
        bgcolor: 'background.default',
        color: 'text.primary',
        borderRadius: 1,
        p: 3,
        border: '1px solid black',
        mb: 2

      }}
    >
        ColorToggler Component

        <IconButton sx={{ ml: 1 }} onClick={colorMode.toggleColorMode} color="inherit">
              {theme.palette.mode === 'dark' ? <Brightness7Icon /> : <Brightness4Icon />}
        </IconButton>
    </Box>    
    </div>
  )
}

export const ThemeGradient = "linear-gradient(90deg, #FCB808 0%, #F9075E 100%)";

export default function Layout() {
  const [mode, setMode] = React.useState('dark');

  const colorMode = React.useMemo(
    () => ({
      toggleColorMode: () => {
        setMode((prevMode) => (prevMode === 'light' ? 'dark' : 'light'));
      },
    }),
    [],
  );

 const theme = React.useMemo(
    () =>
        createTheme({
        status: {
            danger: orange[500],
        },
        palette: {
            mode: mode,
        /*    primary: {
                main: '#556cd6',
            },
            secondary: {
                main: '#19857b',
            },*/
        },
        typography: {
          fontFamily: "Sora, Roboto, sans-serif",
          /* TODO Import sora font from fonts.google.com */
          h1: {
            color: "#FFFFFF",
            fontSize: "55px",
            fontWeight: "semibold"
          },
          subtitle1: {
            color: "#969696",
          },
          subtitle2: {
            color: "white",
            fontSize: "20px",
          },
          body1: {
            color: "#969696",
            fontFamily: "Roboto, sans-serif",
          },
          body2: {
            color: "#969696",
            fontFamily: "Roboto, sans-serif",
          },
        },

        components: {
    
    /*MuiCssBaseline: {
      styleOverrides: {
        body: {
          backgroundColor: '#121212',
        },
      },
    },*/
        MuiButton: {
            styleOverrides: {
                root: {
                    textTransform: 'none',
                    borderRadius: "10px",
                    padding: "10px 30px",
                },
                containedPrimary: {
                    color: "#FFFFFF",
                    background: ThemeGradient,
                },
                outlinedPrimary: {
                    color: "#FFFFFF",
                    background: "transparent",
                    border: "1px solid #424242",
                },

            },
        },
        MuiLink: {
          styleOverrides: {
            root: {
              textDecoration: "none",
              cursor: "pointer",
              fontWeight: "bold",
              color: "#969696",
              "&:hover": {
                color: "#FCB808",
              },
            },
          },
        },        
    }
    }),
    [mode],
    );

  return (
      <ColorModeContext.Provider value={colorMode}>
        <ThemeProvider theme={theme}>
            <CssBaseline />              
            <TopNav />
            <ColorToggler />
            <Outlet />    
            <Footer />        
        </ThemeProvider>
      </ColorModeContext.Provider>      
  );
}