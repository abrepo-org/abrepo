import React, {useState} from 'react';
import ReactDOM from 'react-dom';


const ModalContainer = (props) => {

    const [diff, setDiff] = useState(props.diff);
    const [classNames, setClassNames] = useState(props.classNames || "");

    const isOpen = props.diff ? 'is-active' : '';

    console.log("ModalContainer:", props.diff);
    console.log("isOpen", isOpen);


    return(
        <div className={`modal ${classNames} ${isOpen}`}>
          <div className="modal-background"></div>
          <div className="modal-card">

            <header className="modal-card-head">
              <p className="modal-card-title">Diff</p>
              <button onClick={() => props.modalLaunchHandler(null)}
                className="delete" aria-label="close"></button>
            </header>

            <section className="modal-card-body diffPanel">

              {props.children}

            </section>

            <footer className="modal-card-foot">
              <button className="button is-success">Save changes</button>
              <button className="button">Cancel</button>
            </footer>
          </div>
        </div>
    );

};


export default ModalContainer;
