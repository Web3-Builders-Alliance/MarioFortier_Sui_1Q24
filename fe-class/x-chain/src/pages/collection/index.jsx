import { useEffect, useState } from 'react'


const fetchAllData = async () => {
  const response = await fetch("https://pokeapi.co/api/v2/pokemon/ditto")
    .then( resp => resp.json() )
    .then( data => data.results );
  
  console.log(response);
};

export default function CollectionPage() {
  //const [checkbox, setCheckbox] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // fetch the pokemon data (will mount)
    fetch( "https://pokeapi.co/api/v2/pokemon/ditto")
    

    return () => {
      // Cleanup (on unmount).
    }
  }, [] ); // [] dependencies (call once if empty).

  fetchAllData();
  setIsLoading(false);

  if (isLoading) {
    return <div>Loading...</div>
  }

  return (
    <div>
      Collection Page
    </div>
  )
}