import React, {useState} from 'react';
import ReactDOM from 'react-dom';

const ButtonLaunchModalDetail = (props) => {

    const [diff, setDiff] = useState(props.diff);

    return(
        <button className="diffDetail button is-small"
                onClick={() => { props.modalLaunchHandler(diff) } }>
            Detail
        </button>);
};


export default ButtonLaunchModalDetail;
