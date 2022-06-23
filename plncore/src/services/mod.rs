// This file is Copyright its original authors, visible in version control
// history.
//
// This file is licensed under the Apache License, Version 2.0 <LICENSE-APACHE
// or http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your option.
// You may not use this file except in accordance with one or both of these
// licenses.

pub mod manager;

// /// Serde deserialization decorator to map empty Strings to None,
// fn empty_string_as_none<'de, D, T>(de: D) -> Result<Option<T>, D::Error>
// where
//     D: Deserializer<'de>,
//     T: FromStr,
//     T::Err: fmt::Display,
// {
//     let opt = Option::<String>::deserialize(de)?;
//     match opt.as_deref() {
//         None | Some("") => Ok(None),
//         Some(s) => FromStr::from_str(s).map_err(de::Error::custom).map(Some),
//     }
// }
