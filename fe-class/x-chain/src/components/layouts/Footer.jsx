// import React from 'react';
import Grid from '@mui/material/Grid';
import Stack from '@mui/material/Stack';
import Box from '@mui/material/Box';
import Link from '@mui/material/Link';
import Text from '@mui/material/Typography';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';

import logo from './../../assets/logo.svg';
import IconButton from '@mui/material/IconButton';

import ArrowForwardSharpIcon from '@mui/icons-material/ArrowForwardSharp';


import XIcon from '@mui/icons-material/X';
import FacebookIcon from '@mui/icons-material/Facebook';
import InstagramIcon from '@mui/icons-material/Instagram';
import YouTubeIcon from '@mui/icons-material/YouTube';
import TelegramIcon from '@mui/icons-material/Telegram';
import LinkedInIcon from '@mui/icons-material/LinkedIn';

import discordLogo from '../../assets/icons8-discord.svg';

const DiscordIcon = () => (
  <img src={discordLogo} alt="logo" style={{color:'red'}}></img>
)

const CommunityStack = () => (  
  <Stack direction="row" spacing={2}>
    <Link href="/home"><XIcon/></Link>
    <Link href="/home"><FacebookIcon /></Link>
    <Link href="/home"><InstagramIcon /></Link>
    <Link href="/home"><YouTubeIcon /></Link>
    <Link href="/home"><TelegramIcon /></Link>
    <Link href="/home"><LinkedInIcon /></Link>    
    <Link href="/home"><DiscordIcon /></Link>
  </Stack>
)

const EmailButton = () => (
  <IconButton>
    <ArrowForwardSharpIcon />
  </IconButton>
)

export default function Footer() {
  //const borderStyle = '1px solid #424242';
  const borderStyle = 'none';

  const containerStyle = {
    border: borderStyle,
    alignItems: "left",
  };

  const lightLink = {
    color: 'primary.main',
    fontWeight: 'light',
  };

  const normalLink = {
    color: 'primary.main',
    fontWeight: 'normal',
  };

  return (
    <Box sx={{ display: 'flex', 
               margin: 'auto',
               justifyContent: 'center',
               alignItems: 'center',
               height: '100vh',
               // maxWidth: 1514,
               // maxHeight: 592,
               maxWidth: 1100,
               maxHeight: 350,
               pt: 10
           }}>

    <Stack container direction="column"
          sx={{
            ...containerStyle,
            height: '100%',  
            width: '100%',          
            border: borderStyle,
    }}>
        <Grid container direction="row" sx={{...containerStyle, flex: 0.4}}>
            <Grid item md={6}>
              <Stack>
                <Text variant="h5" sx={{color: 'white'}}>Stay in the Loop</Text>
                <TextField id="filled-basic" sx={{paddingRight:5}} label="Email here..." variant="filled" InputProps={{endAdornment: <EmailButton />}}></TextField>
              </Stack>
            </Grid >
            <Grid item md={6}>
              <Stack>
                <Text variant="h5" sx={{color: 'white'}}>Join the community</Text>
                <CommunityStack />
              </Stack>
            </Grid>
        </Grid>
        <Grid container columns={20} sx={{...containerStyle, flex: 0.5 }}>
            <Grid item md={8} sx={{minWidth:128}}>
              <Stack>
                <Box sx={{ width: 100, height: 38}}>
                  <img src={logo} alt="logo"></img>
                </Box>
                <Text>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Excepteur sint occaecat cupidatat non proident.</Text>
              </Stack>
            </Grid >
            <Grid item md={4} sx={{p: 1}}>
              <Stack sx={{...containerStyle}}>
                <Typography variant="h6">My Account</Typography>
                <Link href="/home" sx={{...normalLink}}>Profile</Link>
                <Link href="/home" sx={{...normalLink}}>My Collections</Link>
                <Link href="/home" sx={{...normalLink}}>Create Item</Link>
                <Link href="/home" sx={{...normalLink}}>Settings</Link>
              </Stack>
            </Grid>
            <Grid item md={4} sx={{p: 1}}>
              <Stack sx={{...containerStyle}}>
                <Typography variant="h6">Resources</Typography>
                <Link href="/home" sx={{...normalLink}}>Help Center</Link>
                <Link href="/home" sx={{...normalLink}}>Partners</Link>
                <Link href="/home" sx={{...normalLink}}>Activity</Link>
                <Link href="/home" sx={{...normalLink}}>Rankings</Link>
              </Stack>
            </Grid >
            <Grid item md={4} sx={{p: 1}}>
              <Stack sx={{...containerStyle}}>
                <Typography variant="h6">Company</Typography>
                <Link href="/Contact" sx={{...normalLink}}>About</Link>
                <Link href="/home" sx={{...normalLink}}>Careers</Link>
                <Link href="/home" sx={{...normalLink}}>Blog</Link>
                <Link href="/home" sx={{...normalLink}}>Contact</Link>
              </Stack>
            </Grid>
        </Grid>
        <Grid container sx={{...containerStyle, flex: 0.1 }}>
            <Grid item md={6}>
              <Text sx={{p:1}}>Merkulove © 2022 Xchain template. All rights reserved.</Text>
            </Grid >
            <Grid item md={6} sx={{textAlign: 'right', p: 1}}>            
              <Link href="/home" sx={{...lightLink}}>Privacy policy</Link>
              &nbsp;&nbsp;|&nbsp;
              <Link href="/home" sx={{...lightLink}}>Terms of service</Link>            
            </Grid>
        </Grid>
    </Stack>
    </Box>
  );
}

// goals:
// make bg #111111
// make 100% width
// separate into 3 columns, with gray border
