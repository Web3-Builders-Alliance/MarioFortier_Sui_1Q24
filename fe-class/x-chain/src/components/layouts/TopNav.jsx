// import React from 'react';
import Grid from '@mui/material/Grid';
import Stack from '@mui/material/Stack';
import Avatar from '@mui/material/Avatar';
import Link from '@mui/material/Link';
import Button from '@mui/material/Button';
import Box from '@mui/material/Box';

import { useNavigate, useLocation } from 'react-router-dom';

import logo from '../../assets/logo.svg';

import { ROUTES } from "../../router/index";
import { ConnectButton } from '@suiet/wallet-kit';

export default function TopNav() {
  const navigate = useNavigate();
  const location = useLocation();
  const currentRoute = location.pathname.split("/")[1];

  function redirect(route) {
    navigate(route);
  }  

  return (
     <Box sx={{ width: "100%" }}>
    <Grid container direction="row" justifyContent="space-between" alignItems="center" sx={{position: 'sticky', top:0, zIndex: 1000}}>
        <Grid container item md={2} sx={{ borderRight: "1px solid #424242", p: 2}}>
            <img src={logo} alt="logo"></img>
        </Grid>
        <Grid item md={3} sx={{ borderRight: "1px solid #424242", p: 2}}>
            Search Component (TBD)
        </Grid>
        <Grid item md={7} sx={{ borderRight: "1px solid #424242", p: 2}}>            
            <Stack direction="row">
            {ROUTES.map((route) => (
              <Link
                key={route}
                disableelevation="true"
                onClick={redirect.bind(null, route.toLowerCase())}
                sx={{
                  color:
                    currentRoute === route.toLowerCase() ||
                    (currentRoute === "" && route === "Home")
                      ? "#ECC808"
                      : "#969696",
                    margin: 2,
                }}
              >
                {route}
              </Link>              
             ))}
              {/*
              <Button sx={{ marginTop: 2, '&:active': {transform: 'none',}, }} variant="outline" onClick={() => redirect('/')}>Home</Button>
              <Button sx={{ marginTop: 2 }} variant="outline" onClick={() => redirect('/explore')}>Explore</Button>
              <Button sx={{ marginTop: 2 }} variant="outline" onClick={() => redirect('/community')}>Community</Button>
              <Button sx={{ marginTop: 2 }} variant="outline" onClick={() => redirect('/about')}>About</Button>              
              */}
              {/*<Button variant="contained" color="primary">Connect Wallet</Button>*/}
              <ConnectButton />
              <Avatar sx={{ marginLeft: 1, marginTop: 1 }} alt="user"></Avatar>
            </Stack>
        </Grid>
    </Grid>
    </Box>
  );
}

// goals:
// make bg #111111
// make 100% width
// separate into 3 columns, with gray border
