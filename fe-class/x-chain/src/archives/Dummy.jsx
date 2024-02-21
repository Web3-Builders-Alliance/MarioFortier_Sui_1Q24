import { useState } from 'react'
import './App.css'

import TextField from "@mui/material/TextField";

function Dummy() {  
  {/* const [localState, setLocalState] = useState('test');*/}

  const [groupState, setGroupState] = useState({ a: 1, b: 'Hello' });

  return (
    <>
      <h1>Dummy Component</h1>
      
      <div>
        <TextField
          id="group-state-edit"
          label="Group.b State"
          variant="filled"
          value={groupState.b}
          onChange={(e) => setGroupState({b:e.target.value})}
        />
      </div>
  
      <div>
        <p>Group State: a: {groupState.a} b:{groupState.b}</p>
        <p>Group State: {JSON.stringify(groupState)}</p> {/* Look into json::stringify */}
      </div>      

{/*
      <div className="card">        
        <TextField
          id="local-state-edit"
          label="Local State"
          variant="outlined"
          value={localState}
          onChange={(e) => setLocalState(e.target.value)}
        />
      </div>

      <div className="card">
        <p>Local State: {localState}</p>
  </div> */}

</>
)  
}

export default Dummy
