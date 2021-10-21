import React, {useState, useEffect} from 'react';
import ReactDOM from 'react-dom';
import ModalContent from './ModalContent.jsx';
import DiffView from './DiffView.jsx';

//props: saved, id
const UserSaveButton = (props) => {

    const [saved, setSaved] = useState(props.saved)

    const url = '/saved';

    const authenticity_token = document
        .querySelector('meta[name="csrf-token"]')
        .getAttribute("content");

    const data = {
        authenticity_token,
        id: props.id
    };

    const userVariationSave = (url, data) => {

        fetch(url, {
            method: "POST",
            headers:  {
                "Accept": "application/json",
                "Content-Type": "application/json"
            },
            body: JSON.stringify(data)
        }).then(res => {
            if (res.ok) return res.json();
            throw new Error('[UserSaveVariation] error');
        }).then(resJSON => {
            setSaved(resJSON.saved)
        }).catch(e => {
            console.error(e);
        });
    };


    if (!props.user_signed_in) return null;

    return(
        <button className="button"
                title="Save"
                onClick={(e) => userVariationSave(url, data) }>

            <span className="icon-text">
                <span className="icon is-small">
                    {saved ?
                     <i className="fas fa-star"></i> :
                     <i className="far fa-star"></i>
                    }
                </span>
            </span>

        </button>
    )

};

export default UserSaveButton;
