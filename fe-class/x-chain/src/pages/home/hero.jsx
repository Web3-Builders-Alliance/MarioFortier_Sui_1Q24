import { Grid, Typography, Stack, Button } from '@mui/material';
import Carousel from 'react-material-ui-carousel';
import { useNavigate } from 'react-router-dom';
import Box from '@mui/material/Box';

export default function Hero() {
    const navigate=useNavigate();

    var items = [
        { 
            name: "Image #1 of 4", // Move this in iterator?
            description: "Image 1 - Description",
            image:
                "https://source.unsplash.com/random?hackers",
        },
        { 
            name: "Image #2 of 4",
            description: "Image 2 - Description",
            image:
                "https://source.unsplash.com/random?steampunk",
        },
        { 
            name: "Image #3 of 4",
            description: "Image 3 - Description",
            image:
                "https://source.unsplash.com/random?scifi",
        },
        { 
            name: "Image #4 of 4",
            description: "Image 4 - Description",
            image:
                "https://source.unsplash.com/random?science",
        }
    ]
    return (
        <>
    
    <Grid container 
        justifyContent="space-between"
        alignItems="center" 
        height="85hv">
        <Grid item sm={12} md={6} sx={{p:4, position: 'relative'}}>            
                <div style={{top: 0, left: 0, zIndex: 0, position: 'absolute'}}
                // position: 'absolute' 
                >                 
                <Box item height={600} width={500} sx={{                            
                            background: "linear-gradient(90deg, #FCB808 0%, #F9075E 100%)",
                            transform: 'rotate(-2deg)'} } ></Box>
                </div>
                
                <div style={{top: 0, left: 0, zIndex: 1}}>
                <Carousel sx={{ background: "#161616", 
                            borderColer: "light-grey",
                            borderRadius: '13px', 
                            borderColor: "lightgray", p:10}}
                    // IndicatorIcon={<>XXXXXX</>}
                    // autoPlay={false}
                    fullHeightHover                
                    interval={5000}>
                    {items.map((item, i) => (
                        <div key={(item, i)}>
                            <img src={item.image} alt="{item.name}" height={500} width='100%' style={{borderRadius: "16px", padding: "10px"}}/>
                            <Typography>{item.name}</Typography>
                        </div>
                    ))}
                </Carousel>                
                </div>
        </Grid>
        <Grid item sm={12} md={6} sx={{p:4}}>
            <Typography variant="h1">Discover the unique digital art of NFT</Typography>
            <Typography variant="subtitle1">Digital marketplace for crypto and blah blah blah</Typography>
            <Stack direction="row">
                <Button variant="contained" color="primary" onClick= {()=> navigate("/explore")}>Explore</Button>
                <Button variant="outlined" color="primary" onClick= {()=> navigate("/create")}>Create</Button>
            </Stack>
        </Grid>
    </Grid> 
    </>
    );
}