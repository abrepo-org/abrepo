import React, {useState} from 'react';
import ReactDOM from 'react-dom';

const ModalContent = (props) => {

    return(
        <>
          <div className='is-size-5'>Details</div>
          <p>{props.diff && props.diff.id}</p>
        </>
    );
};


export default ModalContent;
